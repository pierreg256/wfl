/*
 * commands.js: CLI Commands related to app configuration
 *
 * (C) 2010, Nodejitsu Inc.
 *
 */

var cliDecider = require('./cli-decider');

exports.usage = [
  '`<app> decider *` commands allow you manage your worflow deciders.',
  'Valid commands are:',
  '',
  '<app> decider run <domain-name> <workflow-name>',
];



//
// ### function run (dname, wfname, callback)
// #### @callback {function} Continuation to pass control to when complete
// Lists all the key-value pairs in jitsu config.
//
exports.run = function (dname, wfname, callback) {
  var inspect = require('eyes').inspector();

  var args = Array.prototype.slice.call(arguments);

  callback = args.pop();

  if ((args.length !== 2) || (args[0] == null) || (args[1] == null)){
    cliDecider.app.log.error('You must pass both the <domain-name> and the <workflow-name> parameters');
    return callback(true, true);
  }

  var theDecider;
  try {
    theDecider = require('../../../workers/'+dname+'-'+wfname+'-decider');
  } catch (err) {
    console.log('Error: '.red+'cannot find file : '.cyan+(dname+'-'+wfname+'-decider.js').green+' in the workers directory, please check your source code.'.cyan);
    console.log('Error: '.red+'additional information: '.cyan+err.message.green);
  }

  if (theDecider) {
    console.log('hey');
    var options = {
      'accessKeyId' : this.argv.k || cliDecider.app.config.get('accessKeyId'),
      'secretAccessKey' : this.argv.s || cliDecider.app.config.get('secretAccessKey'),
      'region' : this.argv.r || cliDecider.app.config.get('region') || 'us-east-1',
      'domain': dname,
      'taskList': wfname+'-default-tasklist'
    };
    theDecider.run(options);
  }

  callback();
};

//
// Usage for `<app> config list`
//
exports.run.usage = [
  'Runs the decider for a specific domain and workflow',
  '',
  '<app> decider run <domain-name> <workflow-name>'
];

