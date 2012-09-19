wfl = require './lib/wfl'
inspect = require('eyes').inspector();

options = 
	domain: "wfl-dev-2"
	accessKeyId: "AKIAIATQL3JD74DEDPTQ"
	secretAccessKey: "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"
	force: true 

app = wfl(options)

app.useActivity "hello", (request, response)->
	response.send("Hello")

app.useActivity "world", (request, response)->
	response.send(request.input + ", World!")

app.makeDecision "/start", (request, response)->
	inspect request, "Request"
	response.scheduleActivity("hello", "my name");

app.makeDecision "/start/hello", (request, response)->
	switch request.task.status
		when "SCHEDULED", "STARTED" 
			app.logger.debug "activity hello status: #{request.task.status}"
		when "TIMED_OUT"
			app.logger.debug "activity hello timed out, cancelling the workflow"
			response.cancel("activity hello timed out")
		when "COMPLETED"
			app.logger.debug "activity hello completed"
			response.scheduleActivity "world" if request.success
		else
			response.cancel() 

app.logger.info "Starting application"

app.listen()
setInterval ()->
	app.start({name:"toto", filePath:"/dev/null"})
,25000