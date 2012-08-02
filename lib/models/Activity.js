var inspect = require('eyes').inspector();
var awssum = require('awssum');
var amazon = awssum.load('amazon/amazon');
var Swf = awssum.load('amazon/swf').Swf;
var DecisionTask = require('./ActivityTask').DecisionTask;

var Activity = exports.Activity = function (config, workerFn) {

	this.config = config;
	this.workerFn = workerFn;
	this.swf = new Swf({
	    'accessKeyId' : this.config.accessKeyId,
	    'secretAccessKey' : this.config.secretAccessKey,
	    'region' : this.config.region
	});

	this.poll();
};

Activity.prototype = {

	poll: function() {
		var _this = this;

		console.log('Polling for Activity task...');
		
		this.swf.PollForActivityTask({
				'Domain': _this.config.domain,
				'TaskList': _this.config.taskList
			}, function(err, data){
				if (err) {
					_this.workerFn(err, null, function(continuePolling){
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

				console.log('New activity task received');
				var task = new ActivityTask(_this.swf, body);
				_this.workerFn(null, task, function(continuePolling){
					if (continuePolling) {
						_this.poll();
					}
				});
		});

	}

};