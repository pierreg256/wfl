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
	function (err, decisionTaskData){
		if (err) {
			inspect(err, "Error");
		} else {
			//decisionTaskData.completeWorkflowExecution(function(err, result){
			decisionTaskData.failWorkflowExecution("rien a peter", function(err, result){
			//decisionTaskData.scheduleActivityTask("tata", function(err, result){
				inspect(err, 'Error');
				inspect(result, 'Result');
			});
		}
});


}

