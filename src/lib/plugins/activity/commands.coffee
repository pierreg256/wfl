inspect = require('eyes').inspector()
cliActivity = require('./cli-activity')

exports.usage = [
  '`<app> activity *` commands allow you manage your worflow'
  'activites. Valid commands are:'
  ''
  '<app> activity list <domain-name> '
  '<app> activity create <domain-name>  <activity-name>'
]

exports.list = (domainName, callBack) ->
	if not domainName?
		cliActivity.app.log.error 'You must pass the <domain-name> parameter'
		return callBack(true)

	swfCfg = {
		'accessKeyId' : @argv.k ? cliActivity.app.config.get('accessKeyId')
		'secretAccessKey' : @argv.s ? cliActivity.app.config.get('secretAccessKey')
		'region' : @argv.r ? cliActivity.app.config.get('region') ? 'us-east-1'
	}
	swf = new cliActivity.app.Swf swfCfg

	options = {
		'Domain' : domainName
		'RegistrationStatus' : 'REGISTERED'
	}
	swf.ListActivityTypes options, (err, data)->
		if err?
			cliActivity.app.log.error "An error has occurred with the following details :".red
			inspect err
		else
			cliActivity.app.log.info "Listing all REGISTERED activities".cyan
			activitys = data.Body.typeInfos;
			cliActivity.app.log.info "Name: ".cyan + entry.activityType.name.green + ", Version: ".cyan + entry.activityType.version.green for entry in activitys
			
		process.nextTick ()->callBack

exports.list.usage = [
  'Lists all activitys currently registered'
  'in your default region'
  ''
  '<app> activity list <domain-name>'
]


exports.create = (domainName, activityName, callBack) ->
	if not domainName?
		cliActivity.app.log.error 'You must pass the <domain-name> parameter'
		return callBack true, true
	if not activityName?
		cliActivity.app.log.error 'You must pass the <activity-name> parameter'
		return callBack true, true

	swfCfg = {
		'accessKeyId' : @argv.k ? cliActivity.app.config.get('accessKeyId')
		'secretAccessKey' : @argv.s ? cliActivity.app.config.get('secretAccessKey')
		'region' : @argv.r ? cliActivity.app.config.get('region') ? 'us-east-1'
	}
	swf = new cliActivity.app.Swf swfCfg

	options = {
		"Domain": domainName
		"Name": activityName
		"Version": "1.0"
		"Description": "Automatically created activity type"
		"DefaultTaskStartToCloseTimeout": "600"
		"DefaultTaskHeartbeatTimeout": "120"
		"DefaultTaskList": 
			"name": activityName+"-default-tasklist"
		"DefaultTaskScheduleToStartTimeout": "300"
		"DefaultTaskScheduleToCloseTimeout": "900"
	}
	swf.RegisterActivityType options, (err, data)->
		if err?
			cliActivity.app.log.error "An error has occurred with the following details :"
			inspect err
		else
			cliActivity.app.log.info "Success!"
			
		process.nextTick ()->callBack

exports.create.usage = [
  'Creates an activity for a given domain regsitered '
  'in your default region'
  ''
  '<app> activity create <domain-name> <activity-name>'
]

exports.run = (domainName, activityName, callBack) ->
	if not domainName?
		cliActivity.app.log.error 'You must pass the <domain-name> parameter'
		return callBack true
	if not activityName?
		cliActivity.app.log.error 'You must pass the <activity-name> parameter'
		return callBack true

	fileName = "#{ domainName }-#{activityName}-activity"
	filePath = "../../../workers/#{ fileName }"
	inspect fileName

	try
		theActivity = require filePath
	catch error
		cliActivity.app.log.error "Cannot find file : #{fileName}.js in the workers directory, please check your source code."
		cliActivity.app.log.error "Additional information: #{error.message}"

	if theActivity?
		options = {
			'accessKeyId' : @argv.k ? cliActivity.app.config.get('accessKeyId')
			'secretAccessKey' : @argv.s ? cliActivity.app.config.get('secretAccessKey')
			'region' : @argv.r ? cliActivity.app.config.get('region') ? 'us-east-1'
			'domain': domainName
			'taskList': activityName+'-default-tasklist'
		}
		theActivity.run options

	process.nextTick ()->callBack


