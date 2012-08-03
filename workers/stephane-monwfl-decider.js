var models = require('../lib/models');
var inspect = require('eyes').inspector();

module.exports.run = function(options) {
	inspect(options, 'Options');

	var decider = new models.Decider({
	    'accessKeyId'     : options.accessKeyId,
	    'secretAccessKey' : options.secretAccessKey,
	    'region'          : options.region,
	    'domain'          : options.domain,
	    'taskList'        : {'name': options.taskList}
	}, 
	function (err, decisionTaskData, continuePollingCallback){
		if (err) {
			inspect(err, "Error");
			continuePollingCallback(false);
		} else {
			console.log('got this decision task: ', decisionTaskData);
			decisionTaskData.CompleteWorkflowExecution(function(err, result){
				inspect(err, 'Error');
				inspect(result, 'Result');
				continuePollingCallback(true);
			});
		}
});


}

