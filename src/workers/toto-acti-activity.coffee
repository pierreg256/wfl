inspect = (require 'eyes').inspector()
models = require "../lib/models"

exports.run = (options)->
	inspect options

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

		task.respondCompleted activitiOpt, (error, result)->
			inspect error, "error"
			inspect result, "result"


