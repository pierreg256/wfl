inspect = require('eyes').inspector();
awssum = require('awssum');
amazon = awssum.load('amazon/amazon');
Swf = awssum.load('amazon/swf').Swf;
ActivityTask = require('./ActivityTask').ActivityTask;

class Activity 
	constructor: (@config, @workerFn) ->
		@continuePolling = yes
		swfCfg = 
		    'accessKeyId' : @config.accessKeyId
		    'secretAccessKey' : @config.secretAccessKey
		    'region' : @config.region

		@swf = new Swf swfCfg

		process.nextTick ()=>@poll()


	stop: ()->
		@continuePolling = no;

	poll: ()->
		return if not @continuePolling

		console.log "Polling for next activity task..."

		swfCfg = 
			'Domain': @config.domain
			'TaskList': @config.taskList

		@swf.PollForActivityTask swfCfg, (err, data)=>
			if err?
				process.nextTick ()=>@workerFn err, null
			else
				body = data.Body
				token = body.taskToken
				inspect data
				if not token?
					console.log "No activity task in the pipe, repolling..."
					process.nextTick ()=>@poll()
				else
					console.log "New task received"
					task = new ActivityTask @swf, body
					process.nextTick ()=>
						@workerFn null, task
						@poll()


exports.Activity = Activity