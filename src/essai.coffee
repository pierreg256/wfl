wfl = require './lib/wfl'
inspect = require('eyes').inspector();

options = {
	domain: "wfl-dev-2"
	accessKeyId : "AKIAIATQL3JD74DEDPTQ"
	secretAccessKey : "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"
	force: true
}
app = wfl(options)

app.useActivity "hello", (request, response)->
	response.send("Hello")

app.useActivity "world", (request, response)->
	response.send(request.input + ", World!")

app.makeDecision "/start", (request, response)->
	inspect request, "Request"
	response.scheduleActivity("hello");

app.makeDecision "/start/hello", (request, response)->
	response.scheduleActivity "world" if req.success
	response.cancel() if request.failed

app.logger.info "Starting application"

app.listen()
setInterval ()->
	app.start({name:"toto", filePath:"/dev/null"})
,5000