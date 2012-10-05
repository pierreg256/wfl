inspect = require('eyes').inspector()

wfl_history = require("./wfl-history-cfg").cfg


_getProp= (obj, path) ->
	tmpObj=obj
	for i in path.split(".")
		tmpObj = tmpObj[i]
	return tmpObj

_getEventFromId= (events, id) ->
	result = -1
	(
		result = i if events[i].eventId is id 
	) for i of events
	return result


exports.makeRoute = (events, callBack) ->
	events ?= []
	request = {}
	response = {}
	route = []
	history = []

	#nouvel essai
	pos = events.length - 1
	fini = events.length < 1

	while not (fini or pos < 0)
		handled = false
		evt=events[pos]
		if wfl_history.hasOwnProperty(evt.eventType) and not evt.scanned
			evt_tool = wfl_history[evt.eventType]
			source_evt = events[_getEventFromId(events, _getProp evt, evt_tool.info._eventId)]
			#inspect evt_tool, "wfl-history-detail for #{evt.eventType} "
			#inspect evt, "event to work on"
			#inspect source_evt, "source event"

			request = {}
			if evt_tool.type is "decision"
				request.decisionTask={}
				task = request.decisionTask
			if evt_tool.type is "activity"
				request.activityTask={}
				task = request.activityTask
			if evt_tool.type is "workflow"
				request.workflowTask={}
				task = request.workflowTask

			task.status = evt_tool.status
			(
				if (info.charAt(0) isnt "_")
					#console.log "info: #{info}: #{evt_tool.info[info]}: #{_getProp source_evt, evt_tool.info[info]}"
					task[info]=_getProp source_evt, evt_tool.info[info]
				else
					if info.charAt(1) is "_"
						task[info.substring(2)]=_getProp evt, evt_tool.info[info]
			) for info of evt_tool.info

			#inspect request, "Resulting request"
			source_evt.scanned = true

			#skip the discardable events
			(
				#console.log("events to discard #{i} : #{_getProp(evt,i)}") 
				# dont know why, but sometimes the event to skip is the 0
				evt_id_to_skip = _getProp(evt,i)
				events[_getEventFromId(events,_getProp(evt,i))].scanned = true if evt_id_to_skip isnt 0
			) for i in evt_tool.discard
			
			history.push(request)
		else
			if not evt.scanned
				inspect evt, "Unhandled event type"
				throw "Unhandled event #{evt.eventType} "
				fini = true
			#else
			#	console.log("skipping event: #{evt.eventId}")
		pos--

	#build URL
	request =
		input: null
		url: ""

	history = history.reverse()
	lastActivityId = ""
	(
		tmp = history[i]
		if tmp.workflowTask? and tmp.workflowTask.status is "STARTED"
			request.url += "/start"
			task = tmp.workflowTask
			try
				request.input ?= JSON.parse(task.input)
			catch e
				request.input ?= task.input ? {}

		if tmp.activityTask? 
			#request.url += "/#{tmp.activityTask.name}" if request.url.lastIndexOf(tmp.activityTask.name)<request.url.length-tmp.activityTask.name.length
			request.url += "/#{tmp.activityTask.name}" if lastActivityId isnt tmp.activityTask.id
			request.input = "" if tmp.activityTask.status is "SCHEDULED"
			task = tmp.activityTask
			try
				request.input ?= JSON.parse(task.input)
			catch e
				request.input ?= task.input ? {}

		request.task = task

	) for i of history
	if typeof request.input is 'string'
		try
			request.input = JSON.parse(request.input)
		catch e
			request.input ?= request.input ? {}
	if request.task.result? and typeof request.task.result is 'string'
		try
			request.task.result = JSON.parse(request.task.result)
		catch e
			request.task.result ?= request.task.result ? {}

	#inspect history, "final generated history"
	#inspect request, "final generated request"

	return callBack null, request
