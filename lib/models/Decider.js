var inspect = require('eyes').inspector();
var awssum = require('awssum');
var amazon = awssum.load('amazon/amazon');
var Swf = awssum.load('amazon/swf').Swf;
var DecisionTask = require('./DecisionTask').DecisionTask;

var Decider = exports.Decider = function (config, deciderFn) {

	this.config = config;
	this.deciderFn = deciderFn;
	this.swf = new Swf({
	    'accessKeyId' : this.config.accessKeyId,
	    'secretAccessKey' : this.config.secretAccessKey,
	    'region' : this.config.region
	});

	this.poll();
};

Decider.prototype = {

	poll: function() {
		var _this = this;

		console.log('Polling...');
		
		this.swf.PollForDecisionTask({
				'Domain': _this.config.domain,
				'TaskList': _this.config.taskList
			}, function(err, data){
				if (err) {
					_this.deciderFn(err, null, function(continuePolling){
						if (continuePolling) {
							_this.poll();
						}
					});
					return;
				}

				var body = data.Body; //JSON.parse(data.Body);
				var taskToken = body.taskToken
				
				if (!taskToken) {
					console.log('Elapsed Timeout... Repolling');
					_this.poll();
					return;
				}

				console.log('New decision task received');
				var task = new DecisionTask(_this.swf, body);
				_this.deciderFn(null, task, function(continuePolling){
					if (continuePolling) {
						_this.poll();
					}
				});
		});

	}

};