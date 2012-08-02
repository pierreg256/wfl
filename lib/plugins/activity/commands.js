/*
 * commands.js: CLI Commands related to app configuration
 *
 * (C) 2010, Nodejitsu Inc.
 *
 */

var cliActivity = require('./cli-activity');

exports.usage = [
  '`<app> activity *` commands allow you manage your worflow',
  'activitys. Valid commands are:',
  '',
  '<app> activity list <domain-name> <workflow-name>',
  '<app> activity create <domain-name> <workflow-name> <activity-name>',
];



//
// ### function list (callback)
// #### @callback {function} Continuation to pass control to when complete
// Lists all the key-value pairs in jitsu config.
//
exports.list = function (dname, callback) {
  var inspect = require('eyes').inspector();

  var args = Array.prototype.slice.call(arguments);

  callback = args.pop();

  if ((args.length !== 1) || (args[0] == null)){
    cliActivity.app.log.error('You must pass the <domain-name> parameter');
    return callback(true, true);
  }

  var swf = new cliActivity.app.Swf({
      'accessKeyId' : this.argv.k || cliActivity.app.config.get('accessKeyId'),
      'secretAccessKey' : this.argv.s || cliActivity.app.config.get('secretAccessKey'),
      'region' : this.argv.r || cliActivity.app.config.get('region') || 'us-east-1'
  });

  var options = {
    'Domain' : dname,
    'RegistrationStatus' : 'REGISTERED'
  }
  swf.ListActivityTypes(options, function(err, data) {
    if (err) {
      console.log("\nAn error has occurred with the following details :".red);
      console.log(err.Body.ErrorResponse.Error.Message+'\n');
    } else {
      console.log("\nlisting all REGISTERED activities".cyan);
      var activitys = data.Body.typeInfos;
      for (var entry in activitys) {
        console.log("Name: ".cyan + (activitys[entry].activityType.name +"").green + ", Version: ".cyan + activitys[entry].activityType.version.green);
      }
      console.log("Success!".green);
    }
  });


  callback();
};

//
// Usage for `<app> config list`
//
exports.list.usage = [
  'Lists all activitys currently registered',
  'in your default region',
  '',
  '<app> activity list <domain-name>'
];

//
// ### function create (callback)
// #### @callback {function} Continuation to pass control to when complete
// Create a new workflow activity .
//
exports.create = function (dname, aname, callback) {

  var inspect = require('eyes').inspector();

  var args = Array.prototype.slice.call(arguments);

  callback = args.pop();

  if ((args.length !== 2) || (args[0] == null) || (args[1] == null)){
    cliActivity.app.log.error('You must pass both the <domain-name> AND <activity-name> parameters');
    return callback(true, true);
  }


  var swf = new cliActivity.app.Swf({
      'accessKeyId' : this.argv.k || cliActivity.app.config.get('accessKeyId'),
      'secretAccessKey' : this.argv.s || cliActivity.app.config.get('secretAccessKey'),
      'region' : this.argv.r || cliActivity.app.config.get('region') || 'us-east-1'
  });


  var options = {
    "Domain": dname,
    "Name": aname,
    "Version": "1.0",
    "Description": "Automatically created activity type",
    "DefaultTaskStartToCloseTimeout": "600",
    "DefaultTaskHeartbeatTimeout": "120",
    "DefaultTaskList": {
      "name": aname+"-default-tasklist",
    },
    "DefaultTaskScheduleToStartTimeout": "300",
    "DefaultTaskScheduleToCloseTimeout": "900"
  };


  swf.RegisterActivityType(options, function (err, data){

    if (err) {
      console.log("\nAn error has occurred with the following details :".red);
      inspect(err);
    } else {
      console.log('Success!\n'.green);
    }

    callback();
  });

};

//
// Usage for `<app> config list`
//
exports.create.usage = [
  'Create and register a activity in your aws environment',
  'in your default region',
  '',
  '<app> activity create <activity-name>'
];
