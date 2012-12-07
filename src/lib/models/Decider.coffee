#awssum = require 'awssum'
#amazon = awssum.load 'amazon/amazon'
#Swf = awssum.load('amazon/swf').Swf

AWS = require 'aws-sdk'

inspect = require('eyes').inspector()
routeUtils = require '../utils/routes'

class Response
	constructor: (@app, @swf, @token, @logger)->

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

	end: (result)->
		result ?= ""
		if typeof result isnt "string"
			result = "" + JSON.stringify result
		decisions = [
			"decisionType":"CompleteWorkflowExecution"
			"completeWorkflowExecutionDecisionAttributes":
				"result": result
		]
		@_respondCompleted decisions, (err, data)=>
			@app.logger.verbose "Successfully completed workflow"

	_respondCompleted : (decisions, callBack) ->
		swfCfg = 
	        "taskToken": @token
	        "decisions": decisions
	    @swf.respondDecisionTaskCompleted(swfCfg).always (response)=>
	    	if callBack?
	    		process.nextTick ()->callBack response.error, response.data
	    	else
	    		if response.error?
	    			console.log("Error executing: respondCompleted")
	    		if response.data?
	    			console.log("Successfully executed: respondCompleted")

	_completeWorkflowExecution: (callBack)->
		decisions = [
			"decisionType":"CompleteWorkflowExecution"
			"completeWorkflowExecutionDecisionAttributes":
				"result": "Finished !"
		]
		cBack = callBack ? (err)->
			console.log("Error executing: completeWorkflowExecution") if err?

		@_respondCompleted decisions, cBack


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

		cBack = callBack ? (err)->
			if err?
				inspect err, "Error executing: scheduleActivityTask"
				process.exit 1

		@_respondCompleted decisions, cBack


class Decider
	constructor: (@app)->
		swfCfg = 
			'accessKeyId' : @app.options.accessKeyId
			'secretAccessKey' : @app.options.secretAccessKey
			'region' : @app.options.region

		AWS.config.update(swfCfg);
		SWF = new AWS.SimpleWorkflow #swfCfg
		@swf = SWF.client #swfCfg


		@name ?= "#{@app.options.domain}-#{@app.options.name}-decider"
		@taskList ?= () =>
			"#{@app.options.domain}-#{@app.options.name}-decider-default-tasklist"
		@routes = [];

	addDecision: (route, decisionFn)->
		@routes.push {"route":route, "decisionTask": decisionFn}

	listen: ()->
		process.nextTick ()=>
			@poll()

	poll: () ->
		@app.logger.verbose "Polling for next decision in list:#{@app.options.decider.taskList()}"
		swfCfg = 
			'domain': @app.options.domain,
			'taskList': 
				'name': "#{@app.options.decider.taskList()}"
		request = @swf.pollForDecisionTask swfCfg
		request.done (response)=>
			body = response.data
			token = body.taskToken
			nextPageToken = body.nextPageToken

			if nextPageToken?
				@app.logger.error "Multipage history not yet implemented. Quitting"
				process.exit(1)

			if token?
				routeUtils.makeRoute body.events, (routeError, request)=>
					response = new Response(@app, @swf, token, @logger)

					# Now find the route that fits our request:
					found = false
					(
						if @routes[tmpRoute].route is request.url
							@app.logger.debug "Making following decision: #{@routes[tmpRoute].route}"
							@routes[tmpRoute].decisionTask request, response
							found = true
					) for tmpRoute of @routes
					if not found
						@app.logger.warn "no suitable route found for url: #{request.url}"
						response.cancel("no suitable route found for url: #{request.url} ")
					
			else
				@app.logger.verbose "No decision in the pipe for #{@app.options.decider.taskList()}"

		request.fail (response)=>
			@logger.critical "Unexpected Error polling decision task, see the following details for more info"
			inspect response.error, "Error returned by PollForDecisionTask"
			process.exit (1)

		request.always (response)=>
			#continue polling anyway
			process.nextTick ()=>
				@poll()




exports.Decider = Decider