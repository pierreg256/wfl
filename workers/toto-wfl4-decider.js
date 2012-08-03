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
/*
            decisionTaskData.respondCompleted([
                    {"decisionType": "ScheduleActivityTask",
                     "scheduleActivityTaskDecisionAttributes":
                      {"activityType":
                        {"name": "activityVerify",
                         "version": "1.0"},
                       "activityId": "verification-27",
                       "control": "je sais pas trop quoi mettre ici",
                       "input": "5634-0056-4367-0923,12/12,437",
                       "scheduleToCloseTimeout": "900",
                       "taskList":
                        {"name": "specialTaskList"},
                       "scheduleToStartTimeout": "300",
                       "startToCloseTimeout": "600",
                       "heartbeatTimeout": "120"}
                    }
                ], function(err, result){
                inspect(err, 'Error');
                inspect(result, 'Result');
                continuePollingCallback(true);
            });
*/
			decisionTaskData.CompleteWorkflowExecution(function(err, result){
				inspect(err, 'Error');
				inspect(result, 'Result');
				continuePollingCallback(true);
			});
		}
});


}

