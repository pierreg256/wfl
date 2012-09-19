wfl = require '../lib/wfl'
inspect = require('eyes').inspector();

options = 
	domain: "wfl-dev-2"

app = wfl(options)

app.useActivity "hello", (request, response)->
	response.send("Hello")

app.useActivity "world", (request, response)->
	response.send(request.input + ", World!")

app.makeDecision "/start", (request, response)->
	inspect request, "Request"
	response.scheduleActivity("hello", "my name");

app.makeDecision "/start/hello", (request, response)->
	inspect request, "Activity request in /start/hello decision"
	switch request.task.status
		when "SCHEDULED", "STARTED" 
			app.logger.debug "activity hello status: #{request.task.status}"
		when "TIMED_OUT"
			app.logger.debug "activity hello timed out, cancelling the workflow"
			response.cancel("activity hello timed out")
		when "COMPLETED"
			app.logger.debug "activity hello completed, scheduling world activity"
			response.scheduleActivity "world", request.task.result
		else
			response.cancel("unknown status detected... cancelling") 

app.makeDecision "/start/hello/world", (request, response)->
	switch request.task.status
		when "SCHEDULED", "STARTED" 
			app.logger.debug "activity world status: #{request.task.status}"
		when "TIMED_OUT"
			app.logger.debug "activity world timed out, cancelling the workflow"
			response.cancel("activity world timed out")
		when "COMPLETED"
			app.logger.debug "activity world completed with the following result: #{request.task.result} "
			response.end request.task.result
		else
			response.cancel "unknown status detected... cancelling"

app.logger.info "Starting application"

app.listen()
