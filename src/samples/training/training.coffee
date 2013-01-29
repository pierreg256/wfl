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
	domain: "monday-training"
	name: "hello-world"

app = wfl(options)

#Activities declarations should appear here.
app.useActivity "checkName", (request, response)->
	if request.input? and request.input.length > 0
		response.send {status: "OK", message: "I got an input param: #{request.input}", name:request.input}
	else
		response.send {status: "NOK", message: "no imput provided!"}

app.useActivity "sayHello", (request, response) ->
	reply = "Hello, #{request.input}!"
	response.send {status:"OK", message: reply}

#Routes (Decision Tasks) should appear here.
app.makeDecision "/start", (request, response)->
	response.scheduleActivity "checkName", request.input

app.makeDecision "/start/checkName", (request, response) ->
	if request.task.result.status is "OK"
		response.scheduleActivity "sayHello", request.input
	else
		response.cancel "Activity #{request.task.id} responded in error..."

app.makeDecision "/start/checkName/sayHello", (request, response)->
	response.end request.task.result.message		



app.listen()
