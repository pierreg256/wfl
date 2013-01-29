### 
THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###

wfl = require '../../lib/wfl'
inspect = require('eyes').inspector()

options = 
	domain: "demos"
	name: "hello-world"

app = wfl(options)

app.useActivity "checkName", (request, response)->
	app.logger.debug "#{request.id} - got name: #{request.input.name}}"
	inspect request.input, "input params"
	if request.input? and request.input.length > 0
		response.send {status: "OK", message:"got name: #{request.input}", name:request.input.name}
	else
		response.send {status: "NOK", error:{message:"no name found in the input parameters", code:404}}

app.useActivity "sayHello", (request, response)->
	reply = "Hello, #{request.input}!"
	app.logger.debug "#{request.id} - will answer : #{reply}"
	response.send {status: "OK", message:reply}

app.makeDecision "/start", (request, response)->
	response.scheduleActivity "checkName", request.input

app.makeDecision "/start/checkName", (request, response)->
	if request.task.result.status is "OK"
		response.scheduleActivity "sayHello", request.input
	else
		response.cancel "Activity #{request.task.id} responded in error: #{request.task.result.error.code} - #{request.task.result.error.message}"

app.makeDecision "/start/checkName/sayHello", (request, response)->
	response.end request.task.result.message

app.listen()
