### 
THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###

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