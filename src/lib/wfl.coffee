inspect = require('eyes').inspector()
path = require 'path'
awssum = require 'awssum'
amazon = awssum.load('amazon/amazon')
Swf = awssum.load('amazon/swf').Swf
checkUtils = require './utils/checks'

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
		@options.accessKeyId ?= @config.get("accessKeyId") ? "BAD_KEY"
		@options.secretAccessKey ?= @config.get("secretAccessKey") ? "BAD_SECRET_KEY"
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

		@swf = new Swf swfCfg
		winston = require 'winston'
		@logger = new (winston.Logger)({
    		transports: [
      			new (winston.transports.Console)({'colorize':true, level:'verbose'})
    		]
		});

		if @config.get("noCheck")
			@configStatus = 2


	useActivity: (name, activityFn)->
#		swfCfg = 
#		    'accessKeyId' : @options.accessKeyId
#		    'secretAccessKey' : @options.secretAccessKey
#		    'region' : @options.region
#		localSwfClient = new Swf swfCfg
#		localSwfClient.internalID = name
		@options.activities.push new Activity @, name, activityFn
		# {"name":name, "taskList": "#{name}-default-tasklist", "activityTask": activityFn, "swfClient":}

	makeDecision: (route, decisionFn)->
		@options.decider.addDecision route, decisionFn #routes.push {"route":route, "decisionTask": decisionFn}

	start: (inputValue)->
		@_checkConfig ()=>
			inputValue ?= ""
			if typeof inputValue isnt "string"
				inputValue = "" + JSON.stringify inputValue
			swfCfg = 
				"Domain": @options.domain,
				"WorkflowId": @options.name+"-"+((Math.random()+"").substr(2)),
				"WorkflowType": {"name": @options.name, "version": "1.0"},
				"Input": inputValue
			@swf.StartWorkflowExecution swfCfg, (err, data)=>
				@logger.error "Unexpected error starting workflow", err if err?
				@logger.info "Started workflow execution with the following id: #{swfCfg.WorkflowId}" if data?


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
			checkUtils.checkDomain @swf, @options.domain, @options.force, (err, data)=>
				if err?
					@configStatus = 0
					@logger.error err.message, err.context
				else
					@logger.info "Domain #{@options.domain} checked!"
					checkUtils.checkWorkflow @swf, @options.domain, @options.name, @options.decider.taskList(), @options.force, (errD, dataD)=>
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
										checkUtils.checkActivity @swf, @options.domain, @options.activities[i].name, @options.activities[i].taskList, @options.force, func
									else
										@configStatus = 2
										callBack()
							i=-1
							func()


	_startListeners: ()->
		startActivities = "YES"
		startDecider = "YES"
		if @config.get('activitiesOnly')
			startDecider = "NO"
		if @config.get('deciderOnly')
			startActivities = "NO"
		@logger.info "Workflow application #{@options.domain}/#{@options.name} listening with the following options:"
		@logger.info "   listen for decision tasks: #{startDecider}"
		@logger.info "   listen for activity tasks: #{startActivities}"
		@options.decider.listen() if startDecider is "YES"
		(
			#@logger.debug @options.activities[activ].name #, @options.activities[activ].taskList 
			activ.poll() if startActivities is "YES"
		) for activ, i in @options.activities
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
