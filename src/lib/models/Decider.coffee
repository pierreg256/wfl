inspect = require('eyes').inspector();
awssum = require('awssum');
amazon = awssum.load('amazon/amazon');
Swf = awssum.load('amazon/swf').Swf;
DecisionTask = require('./DecisionTask').DecisionTask;

class Decider
	constructor:(@config, @deciderFn)->
		swfCfg = 
		    'accessKeyId' : @config.accessKeyId
		    'secretAccessKey' : @config.secretAccessKey
		    'region' : @config.region
		@swf = new Swf swfCfg

		process.nextTick ()=>@poll()


	poll: ()->
		console.log "Polling for next decision task (tasklist: #{@config.taskList.name})"

		swfCfg = 
			'Domain': @config.domain,
			'TaskList': @config.taskList
		@swf.PollForDecisionTask swfCfg, (err, data)=>
			if err?
				process.nextTick ()=>@deciderFn err, null
			else
				body = data.Body
				token = body.taskToken

				if token?
					console.log "New decision task received"
					task = new DecisionTask @swf, body
					process.nextTick ()=>@deciderFn null, task

			# Continue Polling anyway
			process.nextTick ()=>@poll()

exports.Decider = Decider
