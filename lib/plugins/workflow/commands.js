/*
 * commands.js: CLI Commands related to app configuration
 *
 * (C) 2010, Nodejitsu Inc.
 *
 */

var cliWorkflow = require('./cli-workflow');

exports.usage = [
  '`wfl workflow *` commands allow you manage your worflow',
  'workflows. Valid commands are:',
  '',
  '<app> workflow list <domain-name>',
  '<app> workflow create <domain-name> <workflow-name>',
  '<app> workflow start <domain-name> <workflow-name>',
];



//
// ### function list (callback)
// #### @callback {function} Continuation to pass control to when complete
// Lists all the key-value pairs in jitsu config.
//
exports.list = function (domainName, callback) {
  var inspect = require('eyes').inspector();

  var args = Array.prototype.slice.call(arguments);

  callback = args.pop();

  if ((args.length !== 1) || (args[0] == null)){
    cliWorkflow.app.log.error('You must pass the <domain-name> parameter');
    return callback(true, true);
  }

  var swf = new cliWorkflow.app.Swf({
      'accessKeyId' : this.argv.k || cliWorkflow.app.config.get('accessKeyId'),
      'secretAccessKey' : this.argv.s || cliWorkflow.app.config.get('secretAccessKey'),
      'region' : this.argv.r || cliWorkflow.app.config.get('region') || 'us-east-1'
  });

  swf.ListWorkflowTypes({ 'Domain' : args[0], 'RegistrationStatus': 'REGISTERED' }, function(err, data) {
    if (err) {
      console.log("\nAn error has occurred with the following details :".red);
      inspect(err);
      //console.log(err.Body.ErrorResponse.Error.Message+'\n');
    } else {
      console.log("\nlisting all REGISTERED workflows");
      var workflows = data.Body.typeInfos;
      for (var entry in workflows) {
        console.log(workflows[entry].workflowType.name+', version: '+workflows[entry].workflowType.version);
      }
      console.log("\n.");
    }
  });


  callback();
};

//
// Usage for `<app> config list`
//
exports.list.usage = [
  'Lists all workflows currently registered for a domain',
  'in your default region',
  '',
  '<app> workflow list <domain-name>'
];

//
// ### function create (callback)
// #### @callback {function} Continuation to pass control to when complete
// Create a new workflow workflow .
//
exports.create = function (dname, wfname, callback) {

  var inspect = require('eyes').inspector();

  var args = Array.prototype.slice.call(arguments);

  callback = args.pop();

  if ((args.length !== 2) || (args[0] == null) || (args[1] == null)){
    cliWorkflow.app.log.error('You must pass the <domain-name> AND <workflow-name> parameter');
    return callback(true, true);
  }


  var swf = new cliWorkflow.app.Swf({
      'accessKeyId' : this.argv.k || cliWorkflow.app.config.get('accessKeyId'),
      'secretAccessKey' : this.argv.s || cliWorkflow.app.config.get('secretAccessKey'),
      'region' : this.argv.r || cliWorkflow.app.config.get('region') || 'us-east-1'
  });

  var options = {
    "Domain": dname,
    "Name": wfname,
    "Version": "1.0",
    "Description": "Automatically created workflow type.",
    "DefaultTaskStartToCloseTimeout": "600",
    "DefaultExecutionStartToCloseTimeout": "3600",
    "DefaultTaskList": {"name": wfname+"-default-tasklist"},
    "DefaultChildPolicy": "TERMINATE"
  };

  swf.RegisterWorkflowType(options, function (err, data){

    if (err) {
      console.log("\nAn error has occurred with the following details :".red);
      console.log(err.Body);
    } else {
      console.log("Success!.\n".green);
    }

    callback();
  });

};

//
// Usage for `<app> config list`
//
exports.create.usage = [
  'Create and register a workflow in your aws environment',
  'in your default region',
  '',
  '<app> workflow create <domain-name> <workflow-name>'
];

//
// ### function start (domain, workflow, input, callback)
// #### @callback {function} Continuation to pass control to when complete
// Create a new workflow workflow .
//
exports.start = function (dname, wfname, input, callback) {

  var inspect = require('eyes').inspector();

  var args = Array.prototype.slice.call(arguments);

  callback = args.pop();

  if ((args.length !== 3) || (args[0] == null) || (args[1] == null)){
    cliWorkflow.app.log.error('You must pass the <domain-name> AND <workflow-name> parameter');
    return callback(true, true);
  }


  var swf = new cliWorkflow.app.Swf({
      'accessKeyId' : this.argv.k || cliWorkflow.app.config.get('accessKeyId'),
      'secretAccessKey' : this.argv.s || cliWorkflow.app.config.get('secretAccessKey'),
      'region' : this.argv.r || cliWorkflow.app.config.get('region') || 'us-east-1'
  });

  var options = {
    "Domain": dname,
    "WorkflowId": wfname+"-"+((Math.random()+"").substr(2)),
    "WorkflowType": {"name": wfname, "version": "1.0"},
    "Input": input || ""
  };


  swf.StartWorkflowExecution(options, function (err, data){

    if (err) {
      console.log("\nAn error has occurred with the following details :".red);
      inspect(err);
    } else {
      console.log("Started workflow: ".cyan+options.WorkflowId.green);
      console.log("With runID:       ".cyan+data.Body.runId.green);
      console.log("\n");
    }

    callback();
  });

};

//
// Usage for `<app> config list`
//
exports.create.start = [
  'Start a workflow in your aws environment',
  'in your default region',
  '',
  '<app> workflow start <domain-name> <workflow-name> [<input-string>]'
];
