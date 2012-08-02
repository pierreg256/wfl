/*
 * commands.js: CLI Commands related to app configuration
 *
 * (C) 2010, Nodejitsu Inc.
 *
 */

var cliDomain = require('./cli-domain');

exports.usage = [
  '`<app> domain *` commands allow you manage your worflow',
  'domains. Valid commands are:',
  '',
  '<app> domain list',
  '<app> domain create <domain-name>',
];



//
// ### function list (callback)
// #### @callback {function} Continuation to pass control to when complete
// Lists all the key-value pairs in jitsu config.
//
exports.list = function (callback) {
  var inspect = require('eyes').inspector();

  var swf = new cliDomain.app.Swf({
      'accessKeyId' : this.argv.k || cliDomain.app.config.get('accessKeyId'),
      'secretAccessKey' : this.argv.s || cliDomain.app.config.get('secretAccessKey'),
      'region' : this.argv.r || cliDomain.app.config.get('region') || 'us-east-1'
  });

  swf.ListDomains({ 'RegistrationStatus' : 'REGISTERED' }, function(err, data) {
    if (err) {
      console.log("\nAn error has occurred with the following details :".red);
      console.log(err.Body.ErrorResponse.Error.Message+'\n');
    } else {
      console.log("\nlisting all REGISTERED domains");
      var domains = data.Body.domainInfos;
      for (var entry in domains) {
        console.log(domains[entry].name);
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
  'Lists all domains currently registered',
  'in your default region',
  '',
  '<app> domain list'
];

//
// ### function create (callback)
// #### @callback {function} Continuation to pass control to when complete
// Create a new workflow domain .
//
exports.create = function (wfname, callback) {

  var inspect = require('eyes').inspector();

  var args = Array.prototype.slice.call(arguments);

  callback = args.pop();

  if ((args.length !== 1) || (args[0] == null)){
    cliDomain.app.log.error('You must pass the <domain-name> parameter');
    return callback(true, true);
  }


  var swf = new cliDomain.app.Swf({
      'accessKeyId' : this.argv.k || cliDomain.app.config.get('accessKeyId'),
      'secretAccessKey' : this.argv.s || cliDomain.app.config.get('secretAccessKey'),
      'region' : this.argv.r || cliDomain.app.config.get('region') || 'us-east-1'
  });

  swf.RegisterDomain({
    'Name': wfname,
    'WorkflowExecutionRetentionPeriodInDays': '1'
  }, function (err, data){

    if (err) {
      console.log("\nAn error has occurred with the following details :".red);
      console.log(err.Body);
    } else {
      console.log('.\n');
    }

    callback();
  });

};

//
// Usage for `<app> config list`
//
exports.create.usage = [
  'Create and register a domain in your aws environment',
  'in your default region',
  '',
  '<app> domain create <domain-name>'
];
