### 
THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###


module.exports.videoChecked = (request, response) ->
	switch request.task.status
		when "TIMED_OUT"
			#app.logger.warn "Activity #{request.task.id} timed out, cancelling the workflow"
			response.cancel("Activity #{request.task.id} timed out")
		when "COMPLETED"
			#app.logger.verbose "Activity #{request.task.id} completed, checking result..."
			if request.task.result.status is "OK"
				if request.task.result.size > 50*1024*1024 #50MB
					#app.logger.verbose "Scheduling activity shortenVideo"
					response.scheduleActivity "shortenVideo", request.input
				else
					#app.logger.verbose "Scheduling activity catCheck"
					response.scheduleActivity "catCheck", request.input
			else
				#app.logger.warn "Activity #{request.task.id} responded in error, (#{request.task.result.error.code} - #{request.task.result.error.message}) cancelling..."
				response.cancel "Activity #{request.task.id} responded in error: #{request.task.result.error.code} - #{request.task.result.error.message}"
		else
			#app.logger.verbose "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"
			response.cancel "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"

module.exports.videoShortened = (request, response) ->
	#app.logger.verbose "Activity #{request.task.id} responded with the following status: #{request.task.status}"
	switch request.task.status
		when "SCHEDULED", "STARTED" 
			response.wait()
		when "TIMED_OUT"
			#app.logger.verbose "Activity #{request.task.id} timed out, cancelling the workflow"
			response.cancel("Activity #{request.task.id} timed out")
		when "COMPLETED"
			#app.logger.verbose "Activity #{request.task.id} completed, checking result..."
			if request.task.result.status is "OK"
				#app.logger.verbose "Sceduling activity catCheck"
				response.scheduleActivity "catCheck", {url:request.input.url}
			else
				#app.logger.verbose "Activity #{request.task.id} responded in error, cancelling..."
				response.cancel "Activity #{request.task.id} responded in error..."
		else
			#app.logger.verbose "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"
			response.cancel "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"


module.exports.catChecked = (request, response) ->
	#app.logger.verbose "Activity #{request.task.id} responded with the following status: #{request.task.status}"
	switch request.task.status
		when "SCHEDULED", "STARTED" 
			response.wait()
		when "TIMED_OUT"
			#app.logger.verbose "Activity #{request.task.id} timed out, cancelling the workflow"
			response.cancel("Activity #{request.task.id} timed out")
		when "COMPLETED"
			#app.logger.verbose "Activity #{request.task.id} completed, checking result..."
			if request.task.result.status is "OK"
				if request.task.result.cats is true
					#app.logger.verbose "Sceduling activity rejectVideo"
					response.scheduleActivity "rejectVideo", {url:request.input.url}
				else
					#app.logger.verbose "Sceduling activity transcodeVideo"
					response.scheduleActivity "transcodeVideo", {url:request.input.url}
			else
				#app.logger.verbose "Activity #{request.task.id} responded in error, cancelling..."
				response.cancel "Activity #{request.task.id} responded in error..."
		else
			#app.logger.verbose "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"
			response.cancel "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"


module.exports.videoTranscoded = (request, response) ->
	#app.logger.verbose "Activity #{request.task.id} responded with the following status: #{request.task.status}"
	switch request.task.status
		when "SCHEDULED", "STARTED" 
			response.wait()
		when "TIMED_OUT"
			#app.logger.verbose "Activity #{request.task.id} timed out, cancelling the workflow"
			response.cancel("Activity #{request.task.id} timed out")
		when "COMPLETED"
			#app.logger.verbose "Activity #{request.task.id} completed, checking result..."
			if request.task.result.status is "OK"
				#app.logger.verbose "Sceduling activity publishVideo"
				response.scheduleActivity "publishVideo", {url:request.input.url}
			else
				#app.logger.verbose "Activity #{request.task.id} responded in error, cancelling..."
				response.cancel "Activity #{request.task.id} responded in error..."
		else
			#app.logger.verbose "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"
			response.cancel "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"

module.exports.videoPublished = (request, response) ->
	#app.logger.verbose "Activity #{request.task.id} responded with the following status: #{request.task.status}"
	switch request.task.status
		when "SCHEDULED", "STARTED" 
			response.wait()
		when "TIMED_OUT"
			#app.logger.verbose "Activity #{request.task.id} timed out, cancelling the workflow"
			response.cancel("Activity #{request.task.id} timed out")
		when "COMPLETED"
			#app.logger.verbose "Activity #{request.task.id} completed, checking result..."
			if request.task.result.status is "OK"
				#app.logger.verbose "Workflow Terminated, signaling end of workflow"
				response.end({status: "OK", message:"Video Published, workflow successfully completed!"})
			else
				#app.logger.verbose "Activity #{request.task.id} responded in error, cancelling..."
				response.cancel "Activity #{request.task.id} responded in error..."
		else
			#app.logger.verbose "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"
			response.cancel "Activity #{request.task.id} ended with an unknown status of #{request.task.status}... cancelling"
