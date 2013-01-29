### 
THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###

inspect = require('eyes').inspector()

exports.checkDomain = (swf, domainName, force, callBack) ->
	force ?= false
	#check domain existence
	swfParams = 
		name: domainName

	request = swf.describeDomain(swfParams)
	request.done (response)=>
		callBack null, response.data.domainInfo.name

	request.fail (response)=>
		if response.error.code is "UnknownResourceFault" 
			if !force
				callBack {err:"NO_DOMAIN", message:"Domain #{domainName} doesnt exist. Please use the --force option to create it."}
			else
				regRequest = swf.registerDomain {name: domainName, workflowExecutionRetentionPeriodInDays: '1'}
				regRequest.done (resp)=>
					callBack null, domainName
				regRequest.fail (resp)=>
					callBack {err: resp.error.code, message: resp.error.message}
		else				
			callBack {err: response.error.code, message: response.error.message}


exports.checkWorkflow = (swf, domainName, workflowName, taskList, force, callBack) ->
	force ?= false
	#check domain existence
	swfParams = 
		domain: domainName
		workflowType: 
			name: workflowName
			version: "1.0"
	request = swf.describeWorkflowType swfParams
	request.done (response)=>
		callBack null, workflowName

	request.fail (response)=>
		if response.error.code is "UnknownResourceFault"
			if !force
				callBack {err:response.error.code, message:"Workflow #{domainName}/#{workflowName} doesnt exist. Please use the force option to create it."}
			else
				swfParams = 
					"domain": domainName,
					"name": workflowName,
					"version": "1.0",
					"description": "Automatically created workflow type.",
					"defaultTaskStartToCloseTimeout": "600",
					"defaultExecutionStartToCloseTimeout": "3600",
					"defaultTaskList": {"name": "#{taskList}"},
					"defaultChildPolicy": "TERMINATE"
				regRequest = swf.registerWorkflowType swfParams
				regRequest.done (resp)=>
					callBack null, domainName
				regRequest.fail (resp)=>
					callBack {err: resp.error.code, message: resp.error.message}
		else
			callBack {err: response.error.code, message: response.error.message}

exports.checkActivity = (swf, domainName, activityName, taskList, force, callBack) ->
	force ?= false
	#check domain existence
	swfParams = 
		domain: domainName
		activityType: 
			name: activityName
			version: "1.0"
	request = swf.describeActivityType swfParams
	request.done (response)=>
		callBack null, activityName

	request.fail (response)=>
		if response.error.code is "UnknownResourceFault"
			if !force
				callBack {err:response.error.code, message:"Activity #{domainName}/#{activityName} doesnt exist. Please use the force option to create it."}
			else
				swfParams = 
					"domain": domainName
					"name": activityName
					"version": "1.0"
					"description": "Automatically created activity type"
					"defaultTaskStartToCloseTimeout": "600"
					"defaultTaskHeartbeatTimeout": "120"
					"defaultTaskList": 
						"name": taskList
					"defaultTaskScheduleToStartTimeout": "300"
					"defaultTaskScheduleToCloseTimeout": "900"
				regRequest = swf.registerActivityType swfParams
				regRequest.done (resp)=>
					callBack null, activityName

				regRequest.fail (resp)=>
					callBack {err:resp.error.code, message: resp.error.message}
		else
			callBack {err:response.error.code, message: response.error.message}

