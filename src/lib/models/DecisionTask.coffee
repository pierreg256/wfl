inspect = require('eyes').inspector();

class DecisionTask
	constructor : (@swf, @task) ->

	respondCompleted : (decisions, callBack) ->
		swfCfg = 
	        "TaskToken": @task.taskToken
	        "Decisions": decisions
	    @swf.RespondDecisionTaskCompleted swfCfg, (err, data)=>
	    	if callBack?
	    		process.nextTick ()->callBack err, data
	    	else
	    		if err?
	    			console.log("Error executing: respondCompleted")
	    		if data?
	    			console.log("Successfully executed: respondCompleted")

	completeWorkflowExecution: (callBack)->
		decisions = [
			"decisionType":"CompleteWorkflowExecution"
			"completeWorkflowExecutionDecisionAttributes":
				"result": "Finished !"
		]
		@respondCompleted decisions, callBack


	failWorkflowExecution: (reason, details..., callBack)-> 
		decisions = [
			"decisionType": "FailWorkflowExecution"
			"failWorkflowExecutionDecisionAttributes":
				"reason": reason
				"details": details[0] ? "none provided by the user" 
		]
		cBack = callBack ? (err)->
			console.log("Error executing: failWorkflowExecution") if err?

		@respondCompleted decisions, cBack

	scheduleActivityTask: (activityName, input..., callBack) ->
		decisions = [
			"decisionType": "ScheduleActivityTask"
			"scheduleActivityTaskDecisionAttributes":
				"activityId": activityName+"-"+((Math.random()+"").substr(2))
				"activityType": 
					"name":  activityName
					"version": "1.0"
				"input": input[0] ? 'none'
				"taskList": 
					"name": activityName+"-default-tasklist"
		]

		inspect decisions
		cBack = callBack ? (err)->
			console.log("Error executing: scheduleActivityTask") if err?

		@respondCompleted decisions, cBack


exports.DecisionTask = DecisionTask