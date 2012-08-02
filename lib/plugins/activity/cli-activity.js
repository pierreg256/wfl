/*
 * flatiron-cli-activity.js: Top-level include for the `flatiron-cli-activity` module.
 *
 * (C) 2010, Nodejitsu Inc.
 *
 */

var common = require('flatiron').common;

var cliActivity = exports;

//
// Expose commands and name this plugin
//
cliActivity.commands = require('./commands');
cliActivity.name = 'cli-activity';

//
// ### function attach (options)
// #### @options {Object} Options to use when attaching
// Attaches the `flatiron-cli-activity` behavior to the application.
//
cliActivity.attach = function (options) {
  var app = this;
  options = options || {};

  if (!app.plugins.cli) {
    throw new Error('`cli` plugin is required to use `cli-activity`');
  }
  else if (!app.config) {
    throw new Error('`app.config` must be set to use `cli-activity`');
  }

  app.config.remove('literal');
  cliActivity.app = app;
  cliActivity.store = options.store || null;
  cliActivity.restricted = options.restricted || [];
  cliActivity.before = options.before || {};
  common.templateUsage(app, cliActivity.commands);

  app.commands['activity'] = app.commands['activity'] || {};
  app.commands['activity'] = common.mixin(app.commands['activity'], cliActivity.commands);
};

//
// ### function detach ()
// Detaches this plugin from the application.
//
cliActivity.detach = function () {
  var app = this;

  Object.keys(app.commands['activity']).forEach(function (method) {
    if (cliActivity.commands[method]) {
      delete app.commands['activity'][method];
    }

    cliActivity.commands.app = null;
  });
};