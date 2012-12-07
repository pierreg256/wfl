inspect = require('eyes').inspector()
path = require 'path'
spawn = require('child_process').spawn
checkUtils = require './utils/checks'

AWS = require 'aws-sdk'

DecisionResponse = require("./models/DecisionResponse").DecisionResponse
ActivityResponse = require("./models/ActivityResponse").ActivityResponse
Activity = require("./models/Activity").Activity
Decider = require("./models/Decider").Decider

createApplication = (options) ->
	app = new Application(options)
	return app


class Application
	constructor: (options)->

		@config = require 'nconf'
		@config.argv().env().file({ file: './swf-config.json' });
		#@config.save (err)->
		#	inspect err, "Config save error" if err?
		# Check the options and define the default values 

		options ?= {}
		@options = options
		@options.force ?= @config.get("force") ? false
		@options.accessKeyId ?= @config.get("accessKeyId") ? @config.get("AWS_ACCESS_KEY") ? "BAD_KEY"
		@options.secretAccessKey ?= @config.get("secretAccessKey") ? @config.get("AWS_SECRET_KEY") ? "BAD_SECRET_KEY"
		@options.region ?= @config.get("region") ? "us-east-1"
		@options.domain ?= @config.get("domain") ? "sample-domain"
		@options.name ?= @config.get("name") ? "sample-workflow"
		@options.decider ?= new Decider(@)
		@options.activities = [];

		#inspect @options, "Options:"

		@configStatus = 0;

		swfCfg = 
		    'accessKeyId' : @options.accessKeyId
		    'secretAccessKey' : @options.secretAccessKey
		    'region' : @options.region

		AWS.config.update(swfCfg);
		@swf = new AWS.SimpleWorkflow #swfCfg
		winston = require 'winston'
		@logger = new (winston.Logger)({
    		transports: [
      			new (winston.transports.Console)({'colorize':true, level:'verbose'})
    		]
		});

		if @config.get("noCheck")
			@configStatus = 2


	useActivity: (name, activityFn)->
		@options.activities.push new Activity @, name, activityFn

	makeDecision: (route, decisionFn)->
		@options.decider.addDecision route, decisionFn #routes.push {"route":route, "decisionTask": decisionFn}

	start: (inputValue)->
		@_checkConfig ()=>
			inputValue ?= ""
			if typeof inputValue isnt "string"
				inputValue = "" + JSON.stringify inputValue
			swfCfg = 
				"domain": @options.domain,
				"workflowId": @options.name+"-"+((Math.random()+"").substr(2)),
				"workflowType": {"name": @options.name, "version": "1.0"},
				"input": inputValue
			@swf.client.startWorkflowExecution(swfCfg).always (response)=>
				@logger.error "Unexpected error starting workflow", response.error if response.error?
				@logger.info "Started workflow execution with the following id: #{swfCfg.workflowId}" if response.data?


	listen: ()->
		@_checkConfig ()=>
			@_startListeners()

	_checkConfig: (callBack) ->
		@configStatus ?= 0

		return (callBack()) if @configStatus is 2

		return (setTimeout ()=>
			@_checkConfig callBack
		, 1000) if @configStatus is 1

		if @configStatus is 0
			@configStatus = 1
			@logger.info "Checking config, please wait..."
			checkUtils.checkDomain @swf.client, @options.domain, @options.force, (err, data)=>
				if err?
					@configStatus = 0
					@logger.error err.message, err.context
				else
					@logger.info "Domain #{@options.domain} checked!"
					checkUtils.checkWorkflow @swf.client, @options.domain, @options.name, @options.decider.taskList(), @options.force, (errD, dataD)=>
						if errD?
							@configStatus = 0
							@logger.error errD.message, errD.context
						else
							@logger.info "Workflow #{@options.name} checked!"
							func = (e, d)=>
								if e?
									@configStatus = 0
									@logger.error e.message, e.context
								else
									i++
									@logger.info "Activity #{@options.activities[i-1].name} checked!" if i>0
									if @options.activities[i]?
										checkUtils.checkActivity @swf.client, @options.domain, @options.activities[i].name, @options.activities[i].taskList, @options.force, func
									else
										@configStatus = 2
										callBack()
							i=-1
							func()


	_startListeners: ()->

		if @config.get("startDecider")
			@logger.debug("starting decider")
			@options.decider.listen()
		else
			#console.log "got: #{@config.get('startActivity')}"
			if @config.get("startActivity")
				activityName = @config.get("startActivity")
				(
					if activ.name is activityName
						activ.poll()
				) for activ, i in @options.activities
				@logger.debug "Starting activity: #{@config.get("startActivity")}"
			else
				(
					@logger.debug "Spawning activity #{activ.name}"
					activityProcess = spawn "node", ["#{module.parent.filename}", "--startActivity",  "#{activ.name}", "--noCheck"]
					activityProcess.stdout.on('data', (data)->
						console.log(data.toString().substr(0, data.toString().length-1))
					)
					activityProcess.stderr.on('data', (data)->
						console.error(data.toString().substr(0, data.toString().length-1))
					)
					activityProcess.on('end', (data)=>
						@logger.debug('end of decider background process...')
					)
					activityProcess.on('exit', (code)=>
						if code isnt 0
							@logger.error "Activity #{activ.name} background process ended abnormally, quitting"
							process.exit 1
					)
				) for activ, i in @options.activities

				@logger.debug("Spawning decider")
				deciderProcess = spawn "node", ["#{module.parent.filename}", "--startDecider", "--noCheck"]
				deciderProcess.stdout.on('data', (data)->
					console.log(data.toString().substr(0, data.toString().length-1))
				)
				deciderProcess.stderr.on('data', (data)->
					console.log(data.toString().substr(0, data.toString().length-1))
				)
				deciderProcess.on('end', (data)=>
					@logger.debug('end of decider background process...')
				)
				deciderProcess.on('exit', (code)=>
					if code isnt 0
						@logger.error "Decider background process ended abnormally, quitting"
						process.exit 1
				)


		#startActivities = "YES"
		#startDecider = "YES"
		#if @config.get('activitiesOnly')
		#	startDecider = "NO"
		#if @config.get('deciderOnly')
		#	startActivities = "NO"
		#@logger.info "Workflow application #{@options.domain}/#{@options.name} listening with the following options:"
		#@logger.info "   listen for decision tasks: #{startDecider}"
		#@logger.info "   listen for activity tasks: #{startActivities}"
		#@options.decider.listen() if startDecider is "YES"
		#(
		#	#@logger.debug @options.activities[activ].name #, @options.activities[activ].taskList 
		#	activ.poll() if startActivities is "YES"
		#) for activ, i in @options.activities
		#process.nextTick ()=>@_listen()

#	_listenForActivity: (activityObject)->
#		@logger.info "Polling for next activity task (#{activityObject.taskList})"
#		#inspect activityObject, "activityObject"
#
#		swfCfg = 
#			'Domain': @options.domain
#			'TaskList': 
#				"name": activityObject.taskList
#
#		activityObject.swfClient.PollForActivityTask swfCfg, (err, data)=>
#			if err?
#				@logger.error "Unexpected Error polling #{swfCfg.TaskList.name} ", err
#			else
#				body = data.Body
#				token = body.taskToken
#				if not token?
#					@logger.info "No activity task in the pipe for #{swfCfg.TaskList.name}, repolling..."
#					#process.nextTick ()=>@_listenForActivity name, taskList
#				else
#					#@logger.debug "TODO: call activity function here!"
#					request = 
#						name: body.activityType.name
#						id: body.activityId
#						workflowId: body.workflowExecution.workflowId
#						input: ""
#						task: body
#					try
#						request.input = JSON.parse(body.input ? "")
#					catch e
#						request.input = body.input ? {}
#
#					response =  new ActivityResponse this, request.name, token
#					#inspect body, "activity data"
#					#inspect request, "activity request"
#					activityFound=false
#					(
#						if @options.activities[i].name is request.name
#							@logger.debug "Running the following activity: #{@options.activities[i].name} "
#							activityFound = true
#							@options.activities[i].activityTask request, response
#					) for i of @options.activities
#					@logger.warn "Unable to find a suitable route for following URL: #{request.url}" if not activityFound
#
#			process.nextTick ()=>
#				@_listenForActivity activityObject
#
#	_listen: ()->
#		@logger.info "Polling for next decision task (tasklist: #{@options.decider.taskList()})"
#
#		swfCfg = 
#			'Domain': @options.domain,
#			'TaskList': 
#				'name': "#{@options.decider.taskList()}"
#		@swf.PollForDecisionTask swfCfg, (err, data)=>
#			if err?
#				@logger.error "Error polling decision task", err
#			else
#				body = data.Body
#				token = body.taskToken
#
#				if token?
#					@logger.info "New decision task received"
#					
#					_makeRoute body.events, (routeError, request)=>
#						response = new DecisionResponse(@, token)
#
#						# Now find the route that fits our request:
#						found = false
#						(
#							if @options.decider.routes[tmpRoute].route is request.url
#								@logger.debug "Making following decision: #{@options.decider.routes[tmpRoute].route}"
#								@options.decider.routes[tmpRoute].decisionTask request, response
#								found = true
#							#else
#							#	@logger.debug "#{@options.decider.routes[tmpRoute].route} is not #{request.url}"
#						) for tmpRoute of @options.decider.routes
#						if not found
#							response.cancel("no suitable route found for url: #{request.url} ")
#						#@logger.debug route, request
#
#
#			# Continue Polling anyway
#			process.nextTick ()=>@_listen()







module.exports = createApplication
