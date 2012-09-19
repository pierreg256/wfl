inspect = require('eyes').inspector();

class ActivityResponse
	constructor : (@app, @token) ->

	send: (result, cBack)->
		if typeof result isnt "string"
			result = JSON.stringify(result)

		swfCfg = 
			"TaskToken": @token
			"Result": result

		cBack = callBack ? (err)->
			@pp.logger.error "Error sending activity response", err  if err?

		@app.swf.RespondActivityTaskCompleted swfCfg, cBack

exports.ActivityResponse = ActivityResponse