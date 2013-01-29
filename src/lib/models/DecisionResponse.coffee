### 
THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###

inspect = require('eyes').inspector();

class DecisionResponse
	constructor : (@app, @token) ->

	scheduleActivity: (activityName, inputValue) ->
		inputValue ?= ""
		if typeof inputValue isnt "string"
			inputValue = "" + JSON.stringify inputValue

		# find the task list from the activity name
		taskList = ""
		(
			if @app.options.activities[acti].name is activityName
				taskList = @app.options.activities[acti].taskList
		) for acti of @app.options.activities
		@_scheduleActivityTask activityName, taskList, inputValue

	cancel: (reason)->
		@_failWorkflowExecution(reason)

	end: (result)->
		result ?= ""
		if typeof result isnt "string"
			result = "" + JSON.stringify result
		decisions = [
			"decisionType":"CompleteWorkflowExecution"
			"completeWorkflowExecutionDecisionAttributes":
				"result": result
		]
		@_respondCompleted decisions

	_respondCompleted : (decisions, callBack) ->
		swfCfg = 
	        "TaskToken": @token
	        "Decisions": decisions
	    @app.swf.RespondDecisionTaskCompleted swfCfg, (err, data)=>
	    	if callBack?
	    		process.nextTick ()->callBack err, data
	    	else
	    		if err?
	    			console.log("Error executing: respondCompleted")
	    		if data?
	    			console.log("Successfully executed: respondCompleted")

	_completeWorkflowExecution: (callBack)->
		decisions = [
			"decisionType":"CompleteWorkflowExecution"
			"completeWorkflowExecutionDecisionAttributes":
				"result": "Finished !"
		]
		@_respondCompleted decisions, callBack


	_failWorkflowExecution: (reason, details..., callBack)-> 
		decisions = [
			"decisionType": "FailWorkflowExecution"
			"failWorkflowExecutionDecisionAttributes":
				"reason": reason
				"details": details[0] ? "none provided by the user" 
		]
		cBack = callBack ? (err)->
			console.log("Error executing: failWorkflowExecution") if err?

		@_respondCompleted decisions, cBack

	_scheduleActivityTask: (activityName, taskList, inputValue, callBack) ->
		decisions = [
			"decisionType": "ScheduleActivityTask"
			"scheduleActivityTaskDecisionAttributes":
				"activityId": activityName+"-"+((Math.random()+"").substr(2))
				"activityType": 
					"name":  activityName
					"version": "1.0"
				"input": inputValue
				"taskList": 
					"name": taskList
		]

		#inspect decisions
		cBack = callBack ? (err)->
			console.log("Error executing: scheduleActivityTask") if err?

		@_respondCompleted decisions, cBack


exports.DecisionResponse = DecisionResponse