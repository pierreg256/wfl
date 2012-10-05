inspect = require('eyes').inspector();

class ActivityResponse
	constructor : (@app, name, @token) ->
		(
			if @app.activities[i].name is name
				@swf = @app.activities[i].swfClient
		) for i of @app.activities

	send: (result, cBack)->
		if typeof result isnt "string"
			result = JSON.stringify(result)

		swfCfg = 
			"TaskToken": @token
			"Result": result

		cBack = callBack ? (err)->
			@pp.logger.error "Error sending activity response", err  if err?

		@swf.RespondActivityTaskCompleted swfCfg, cBack

exports.ActivityResponse = ActivityResponse