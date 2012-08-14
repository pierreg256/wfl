inspect = require('eyes').inspector();
awssum = require('awssum');
amazon = awssum.load('amazon/amazon');
Swf = awssum.load('amazon/swf').Swf;
DecisionTask = require('./ActivityTask').DecisionTask;

class Activity 
	constructor: (@config, @workerFn) ->
		swfCfg = 
		    'accessKeyId' : @config.accessKeyId
		    'secretAccessKey' : @config.secretAccessKey
		    'region' : @config.region

		@swf = new Swf swfCfg

		process.nextTick ()->@poll()


	poll: ()->
		console.log "Polling for next activity task..."

		swfCfg = 
			'Domain': @config.domain
			'TaskList': @config.taskList

		@swf.PollForActivityTask swfCfg, (err, data)->
			if err?
				process.nextTick ()->@workerFn err, null
			else
				body = data.Body
				token = data.taskToken

				if not taskToken?
					console.log "No activity task in the pipe, repolling..."
					process.nextTick ()->@poll()
				else
					console.log "New task received"
					task = new ActivityTask @swf, body
					process.nextTick ()->@workerFn null, task


exports.Activity = Activity