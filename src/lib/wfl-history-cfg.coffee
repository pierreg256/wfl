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
				"startedEventId"
			]
		"info":
			"_eventId": "scheduledEventId"
			"name": "activityTaskScheduledEventAttributes.activityType.name"
			"id": "activityTaskScheduledEventAttributes.activityId"
			"input": "activityTaskScheduledEventAttributes.input"

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