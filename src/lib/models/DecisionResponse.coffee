inspect = require('eyes').inspector();

class DecisionResponse
	constructor : (@app, @token) ->

	scheduleActivity: (activityName, inputValue) ->
		inputValue ?= ""
		if typeof inputValue isnt "string"
			inputValue = "" + JSON.stringify inputValue

		# find the task list from the activity name
		taskList = ""
		(
			if @app.options.activities[acti].name is activityName
				taskList = @app.options.activities[acti].taskList
		) for acti of @app.options.activities
		@_scheduleActivityTask activityName, taskList, inputValue

	cancel: (reason)->
		@_failWorkflowExecution(reason)

	_respondCompleted : (decisions, callBack) ->
		swfCfg = 
	        "TaskToken": @token
	        "Decisions": decisions
	    @app.swf.RespondDecisionTaskCompleted swfCfg, (err, data)=>
	    	if callBack?
	    		process.nextTick ()->callBack err, data
	    	else
	    		if err?
	    			console.log("Error executing: respondCompleted")
	    		if data?
	    			console.log("Successfully executed: respondCompleted")

	_completeWorkflowExecution: (callBack)->
		decisions = [
			"decisionType":"CompleteWorkflowExecution"
			"completeWorkflowExecutionDecisionAttributes":
				"result": "Finished !"
		]
		@respondCompleted decisions, callBack


	_failWorkflowExecution: (reason, details..., callBack)-> 
		decisions = [
			"decisionType": "FailWorkflowExecution"
			"failWorkflowExecutionDecisionAttributes":
				"reason": reason
				"details": details[0] ? "none provided by the user" 
		]
		cBack = callBack ? (err)->
			console.log("Error executing: failWorkflowExecution") if err?

		@_respondCompleted decisions, cBack

	_scheduleActivityTask: (activityName, taskList, inputValue, callBack) ->
		decisions = [
			"decisionType": "ScheduleActivityTask"
			"scheduleActivityTaskDecisionAttributes":
				"activityId": activityName+"-"+((Math.random()+"").substr(2))
				"activityType": 
					"name":  activityName
					"version": "1.0"
				"input": inputValue
				"taskList": 
					"name": taskList
		]

		#inspect decisions
		cBack = callBack ? (err)->
			console.log("Error executing: scheduleActivityTask") if err?

		@_respondCompleted decisions, cBack


exports.DecisionResponse = DecisionResponse