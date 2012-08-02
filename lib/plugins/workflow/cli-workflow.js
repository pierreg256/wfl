/*
 * flatiron-cli-workflow.js: Top-level include for the `flatiron-cli-workflow` module.
 *
 * (C) 2010, Nodejitsu Inc.
 *
 */

var common = require('flatiron').common;

var cliWorkflow = exports;

//
// Expose commands and name this plugin
//
cliWorkflow.commands = require('./commands');
cliWorkflow.name = 'cli-workflow';

//
// ### function attach (options)
// #### @options {Object} Options to use when attaching
// Attaches the `flatiron-cli-workflow` behavior to the application.
//
cliWorkflow.attach = function (options) {
  var app = this;
  options = options || {};

  if (!app.plugins.cli) {
    throw new Error('`cli` plugin is required to use `cli-workflow`');
  }
  else if (!app.config) {
    throw new Error('`app.config` must be set to use `cli-workflow`');
  }

  app.config.remove('literal');
  cliWorkflow.app = app;
  cliWorkflow.store = options.store || null;
  cliWorkflow.restricted = options.restricted || [];
  cliWorkflow.before = options.before || {};
  common.templateUsage(app, cliWorkflow.commands);

  app.commands['workflow'] = app.commands['workflow'] || {};
  app.commands['workflow'] = common.mixin(app.commands['workflow'], cliWorkflow.commands);
  app.alias('wfl', { resource: 'workflow', command: 'list' });
};

//
// ### function detach ()
// Detaches this plugin from the application.
//
cliWorkflow.detach = function () {
  var app = this;

  Object.keys(app.commands['workflow']).forEach(function (method) {
    if (cliWorkflow.commands[method]) {
      delete app.commands['workflow'][method];
    }

    cliWorkflow.commands.app = null;
  });
};