inspect = require('eyes').inspector();

class ActivityTask
	constructor: (@swf, @task)->

	respondCompleted: (result, callBack)->
		if typeof result isnt "string"
			result = JSON.stringify(result)

		swfCfg = 
			"TaskToken": @task.taskToken
			"Result": result

		cBack = callBack ? (err)->
			console.log("Error executing: respondCompleted") if err?

		@swf.RespondActivityTaskCompleted swfCfg, cBack

exports.ActivityTask = ActivityTask