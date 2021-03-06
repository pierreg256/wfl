### 
THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###

wflHistoryCfg =
	"WorkflowExecutionStarted":
		"type": "workflow"
		"status": "STARTED"
		"discard": []
		"info":
			"_eventId": "eventId"
			"name": "workflowExecutionStartedEventAttributes.workflowType.name"
			"input": "workflowExecutionStartedEventAttributes.input"

	"DecisionTaskStarted":
		"type": "decision"
		"status": "STARTED"
		"discard": []
		"info":
			"_eventId": "decisionTaskStartedEventAttributes.scheduledEventId"
			"name": "decisionTaskScheduledEventAttributes.taskList.name"

	"DecisionTaskTimedOut":
		"type": "decision"
		"status": "TIMED_OUT"
		"discard": [
			"decisionTaskTimedOutEventAttributes.startedEventId"
		]
		"info":
			"_eventId": "decisionTaskTimedOutEventAttributes.scheduledEventId"
			"name": "decisionTaskScheduledEventAttributes.taskList.name"

	"DecisionTaskCompleted":
		"type": "decision"
		"status": "COMPLETED"
		"discard": [
			"decisionTaskCompletedEventAttributes.startedEventId"
		]
		"info":
			"_eventId": "decisionTaskCompletedEventAttributes.scheduledEventId"
			"name": "decisionTaskScheduledEventAttributes.taskList.name"

	"ActivityTaskCompleted":
		"type": "activity"
		"status": "COMPLETED"
		"discard": [
				"activityTaskCompletedEventAttributes.startedEventId"
			]
		"info":
			"_eventId": "activityTaskCompletedEventAttributes.scheduledEventId"
			"name": "activityTaskScheduledEventAttributes.activityType.name"
			"id": "activityTaskScheduledEventAttributes.activityId"
			"__result": "activityTaskCompletedEventAttributes.result"

	"ActivityTaskTimedOut":
		"type": "activity"
		"status": "TIMED_OUT"
		"discard": [
				"activityTaskTimedOutEventAttributes.startedEventId"
			]
		"info":
			"_eventId": "activityTaskTimedOutEventAttributes.scheduledEventId"
			"name": "activityTaskScheduledEventAttributes.activityType.name"
			"id": "activityTaskScheduledEventAttributes.activityId"

exports.cfg = wflHistoryCfg