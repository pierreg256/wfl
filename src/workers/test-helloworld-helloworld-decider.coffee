inspect = (require 'eyes').inspector()
models = require "../lib/models"

exports.run = (options)->

	decisionTaskOptions = {
		'accessKeyId'     : options.accessKeyId
		'secretAccessKey' : options.secretAccessKey
		'region'          : options.region
		'domain'          : options.domain
		'taskList'        : 
			'name': options.taskList
	}

	decider = new models.Decider decisionTaskOptions, (error, decisionTask)->
		if err?
			inspect error, "Got the following error"
		else
			inspect decisionTask.task, "Got the following decision task"

			if decisionTask.isFailedActivity "hello", "world"
				decisionTask.failWorkflowExecution "Hello or activity task failed", decisionTask.workflowHistory
				return

			if decisionTask.isCancelledActivity "hello", "world"
				decisionTask.failWorkflowExecution "Hello or activity task cancelled", decisionTask.workflowHistory
				return

			if decisionTask.isTaskCompleted "hello"
				decisionTask.scheduleActivityTask "world", decisionTask.activityTaskCompletedResult "hello"
			else
				decisionTask.scheduleActivityTask "hello", decisionTask.workflowInput



