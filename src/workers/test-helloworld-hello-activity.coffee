inspect = (require 'eyes').inspector()
models = require "../lib/models"

exports.run = (options)->

	activitiOpt = {
		'accessKeyId'     : options.accessKeyId,
		'secretAccessKey' : options.secretAccessKey,
		'region'          : options.region,
		'domain'          : options.domain,
		'taskList'        : 
			'name': options.taskList
	}
	activity = new models.Activity activitiOpt, (err, task)->
		if err?
			console.log("Error while executing: new Activity")

		inspect task, "Got task:"

		activityResult = {"value": "Hello, "};
		task.respondCompleted activityResult, (error, result)->
			inspect error, "error" if error?



