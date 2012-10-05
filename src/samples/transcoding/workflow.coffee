wfl = require '../../lib/wfl'
inspect = require('eyes').inspector();

options = 
	domain: "demos"
	name: "transcoder"

app = wfl(options)

app.useActivity "checkVideo", (request, response)->
	app.logger.verbose "#{request.id} - Checking video: #{request.input.url}"
	response.send {status: "OK", message:"Found Video in S3", size:1257}

app.useActivity "shortenVideo", (request, response)->
	app.logger.verbose "#{request.id} - Shortening video: #{request.input.url}"
	response.send {status: "OK", message:"Video Shortened successfully"}

app.useActivity "catCheck", (request, response)->
	app.logger.verbose "#{request.id} - Checking video: #{request.input.url} for cats"
	response.send {status: "OK", message:"Clean Video", cats:false}

app.useActivity "rejectVideo", (request, response)->
	app.logger.verbose "#{request.id} - Rejected video: #{request.input.url}. sending email to the user"
	response.send {status: "OK", message:"Video Rejected"}

app.useActivity "transcodeVideo", (request, response)->
	app.logger.verbose "#{request.id} - Transcoding video: #{request.input.url}."
	response.send {status: "OK", message:"Transcoded to format H264/AAC"}

app.useActivity "publishVideo", (request, response)->
	app.logger.verbose "#{request.id} - Publishing video: #{request.input.url}. sending email to the user"
	response.send {status: "OK", message:"Video Published"}


app.makeDecision "/start", (request, response)->
	app.logger.verbose "Sceduling activity checkVideo"
	response.scheduleActivity "checkVideo", {url: request.input.url}

app.makeDecision "/start/checkVideo", (request, response)->
	app.logger.verbose "Activity #{request.task.id} responded with the following status: #{request.task.status}"
	switch request.task.status
		when "SCHEDULED", "STARTED" 
			response.wait()
		when "TIMED_OUT"
			app.logger.verbose "Activity #{request.task.id} timed out, cancelling the workflow"
			response.cancel("Activity #{request.task.id} timed out")
		when "COMPLETED"
			app.logger.verbose "Activity #{request.task.id} completed, checking result..."
			if request.task.result.status is "OK"
				if request.task.result.size > 128
					app.logger.verbose "Sceduling activity shortenVideo"
					response.scheduleActivity "shortenVideo", {url:request.input.url}
				else
					app.logger.verbose "Sceduling activity catCheck"
					response.scheduleActivity "catCheck", {url:request.input.url}
			else
				app.logger.verbose "Activity #{request.task.id} responded in error, cancelling..."
				response.cancel "Activity #{request.task.id} responded in error..."
		else
			app.logger.verbose "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"
			response.cancel "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"

app.makeDecision "/start/checkVideo/shortenVideo", (request, response)->
	app.logger.verbose "Activity #{request.task.id} responded with the following status: #{request.task.status}"
	switch request.task.status
		when "SCHEDULED", "STARTED" 
			response.wait()
		when "TIMED_OUT"
			app.logger.verbose "Activity #{request.task.id} timed out, cancelling the workflow"
			response.cancel("Activity #{request.task.id} timed out")
		when "COMPLETED"
			app.logger.verbose "Activity #{request.task.id} completed, checking result..."
			if request.task.result.status is "OK"
				app.logger.verbose "Sceduling activity catCheck"
				response.scheduleActivity "catCheck", {url:request.input.url}
			else
				app.logger.verbose "Activity #{request.task.id} responded in error, cancelling..."
				response.cancel "Activity #{request.task.id} responded in error..."
		else
			app.logger.verbose "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"
			response.cancel "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"

app.makeDecision "/start/checkVideo/shortenVideo/catCheck", (request, response)->
	app.logger.verbose "Activity #{request.task.id} responded with the following status: #{request.task.status}"
	switch request.task.status
		when "SCHEDULED", "STARTED" 
			response.wait()
		when "TIMED_OUT"
			app.logger.verbose "Activity #{request.task.id} timed out, cancelling the workflow"
			response.cancel("Activity #{request.task.id} timed out")
		when "COMPLETED"
			app.logger.verbose "Activity #{request.task.id} completed, checking result..."
			if request.task.result.status is "OK"
				if request.task.result.cats is true
					app.logger.verbose "Sceduling activity rejectVideo"
					response.scheduleActivity "rejectVideo", {url:request.input.url}
				else
					app.logger.verbose "Sceduling activity transcodeVideo"
					response.scheduleActivity "transcodeVideo", {url:request.input.url}
			else
				app.logger.verbose "Activity #{request.task.id} responded in error, cancelling..."
				response.cancel "Activity #{request.task.id} responded in error..."
		else
			app.logger.verbose "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"
			response.cancel "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"



app.listen()
