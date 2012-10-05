awssum = require 'awssum'
amazon = awssum.load 'amazon/amazon'
Swf = awssum.load('amazon/swf').Swf;


class Response
	constructor:(@swf, @token, @logger)->

	send: (result, callBack)->
		if typeof result isnt "string"
			result = JSON.stringify(result)

		swfCfg = 
			"TaskToken": @token
			"Result": result

		callBack ?=  (err, result)=>
			if err?
				@app.logger.error "Error sending activity response", err  if err?
				process.exit 1
			@logger.verbose "RespondActivityTaskCompleted sent successfully with the following result: #{result} "


		@logger.verbose "Sending activity response to SWF..."
		@swf.RespondActivityTaskCompleted swfCfg, callBack

	cancel:(result, callBack)->
		if typeof result isnt "string"
			result = JSON.stringify(result)

		swfCfg = 
			"TaskToken": @token
			"Details": result

		callBack ?=  (err, result)=>
			if err?
				@app.logger.error "Error cancelling activity", err  if err?
				inspect err, "Error message"
				process.exit 1
			@logger.verbose "RespondActivityTaskCanceled sent successfully with the following detail: #{result} "


		@logger.verbose "Sending activity response to SWF..."
		@swf.RespondActivityTaskCanceled swfCfg, callBack


class Activity
	constructor: (@app, @name, @coreFn)->
		@taskList= "#{name}-default-tasklist"
		swfCfg = 
			'accessKeyId' : @app.options.accessKeyId
			'secretAccessKey' : @app.options.secretAccessKey
			'region' : @app.options.region
		@swf = new Swf swfCfg

	poll: ()->
		@app.logger.verbose "Polling for next task for: #{@name} in list:#{@taskList}"

		swfCfg = 
			'Domain': @app.options.domain
			'TaskList': 
				"name": @taskList

		@swf.PollForActivityTask swfCfg, (err, data)=>
			if err?
				@app.logger.error "Unexpected Error polling #{@taskList} ", err
				process.exit 1
			else
				body = data.Body
				token = body.taskToken
				if not token?
					@app.logger.verbose "No activity task in the pipe for #{@taskList}, repolling..."
				else
					@app.logger.verbose "New Activity task received for: #{@name} in list:#{@taskList}"
					request = 
						name: body.activityType.name
						id: body.activityId
						workflowId: body.workflowExecution.workflowId
						input: ""
						task: body
					try
						request.input = JSON.parse(body.input ? "")
					catch e
						request.input = body.input ? {}

					response =  new Response @swf, token, @app.logger
					@app.logger.verbose "Start running activity: #{@name} with id: #{request.id} "
					@coreFn request, response

			process.nextTick ()=>
				@poll()




exports.Activity = Activity