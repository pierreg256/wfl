exports.checkDomain = (swf, domainName, force, callBack) ->
	force ?= false
	#check domain existence
	swfParams = 
		Name: domainName
	swf.DescribeDomain swfParams, (descDomainErr, descDomainData) =>
		if descDomainErr?
			if descDomainErr.Body? and descDomainErr.Body.__type? and descDomainErr.Body.__type.indexOf("UnknownResourceFault") > -1
				if !force
					#@logger.warn "Domain #{@options.domain} doesnt exist. Please use the force option to create it."
					callBack {err:"NO_DOMAIN", message:"Domain #{domainName} doesnt exist. Please use the force option to create it."}
				else
					swfParams = 
					    'Name': domainName,
					    'WorkflowExecutionRetentionPeriodInDays': '1'
					swf.RegisterDomain swfParams, (regDomainErr, regDomainData)->
						if regDomainErr?
							callBack {err:"UNEXPECTED", message:"Unexpected error encountered", context:regDomainErr}
						else
							callBack null, domainName
			else
				callBack {err:"UNEXPECTED", message:"Unexpected error encountered", context:descDomainErr}
		else
			callBack null, domainName

exports.checkWorkflow = (swf, domainName, workflowName, taskList, force, callBack) ->
	force ?= false
	#check domain existence
	swfParams = 
		Domain: domainName
		WorkflowType: 
			name: workflowName
			version: "1.0"
	swf.DescribeWorkflowType swfParams, (descWflErr, descWflData) =>
		if descWflErr?
			if descWflErr.Body? and descWflErr.Body.__type? and descWflErr.Body.__type.indexOf("UnknownResourceFault") > -1
				if !force
					#@logger.warn "Domain #{@options.domain} doesnt exist. Please use the force option to create it."
					callBack {err:"NO_WORKFLOW", message:"Workflow #{domainName}/#{workflowName} doesnt exist. Please use the force option to create it."}
				else
					swfParams = 
						"Domain": domainName,
						"Name": workflowName,
						"Version": "1.0",
						"Description": "Automatically created workflow type.",
						"DefaultTaskStartToCloseTimeout": "600",
						"DefaultExecutionStartToCloseTimeout": "3600",
						"DefaultTaskList": {"name": "#{taskList}"},
						"DefaultChildPolicy": "TERMINATE"
					swf.RegisterWorkflowType swfParams, (regWflErr, regWflData)->
						if regWflErr?
							callBack {err:"UNEXPECTED", message:"Unexpected error encountered", context:regWflErr}
						else
							callBack null, workflowName
			else
				callBack {err:"UNEXPECTED", message:"Unexpected error encountered", context:descWflErr}
		else
			callBack null, workflowName

exports.checkActivity = (swf, domainName, activityName, taskList, force, callBack) ->
	force ?= false
	#check domain existence
	swfParams = 
		Domain: domainName
		ActivityType: 
			name: activityName
			version: "1.0"
	swf.DescribeActivityType swfParams, (descActErr, descActData) =>
		if descActErr?
			if descActErr.Body? and descActErr.Body.__type? and descActErr.Body.__type.indexOf("UnknownResourceFault") > -1
				if !force
					callBack {err:"NO_ACTIVITY", message:"Activity #{domainName}/#{activityName} doesnt exist. Please use the force option to create it."}
				else
					swfParams = 
						"Domain": domainName
						"Name": activityName
						"Version": "1.0"
						"Description": "Automatically created activity type"
						"DefaultTaskStartToCloseTimeout": "600"
						"DefaultTaskHeartbeatTimeout": "120"
						"DefaultTaskList": 
							"name": taskList
						"DefaultTaskScheduleToStartTimeout": "300"
						"DefaultTaskScheduleToCloseTimeout": "900"
					swf.RegisterActivityType swfParams, (regActErr, regActData)->
						if regActErr?
							callBack {err:"UNEXPECTED", message:"Unexpected error encountered", context:regActErr}
						else
							callBack null, activityName
			else
				callBack {err:"UNEXPECTED", message:"Unexpected error encountered", context:descActErr}
		else
			callBack null, activityName
