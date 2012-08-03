/*
 * flatiron-cli-decider.js: Top-level include for the `flatiron-cli-decider` module.
 *
 * (C) 2010, Nodejitsu Inc.
 *
 */

var common = require('flatiron').common;

var cliDecider = exports;

//
// Expose commands and name this plugin
//
cliDecider.commands = require('./commands');
cliDecider.name = 'cli-decider';

//
// ### function attach (options)
// #### @options {Object} Options to use when attaching
// Attaches the `flatiron-cli-decider` behavior to the application.
//
cliDecider.attach = function (options) {
  var app = this;
  options = options || {};

  if (!app.plugins.cli) {
    throw new Error('`cli` plugin is required to use `cli-decider`');
  }
  else if (!app.config) {
    throw new Error('`app.config` must be set to use `cli-decider`');
  }

  app.config.remove('literal');
  cliDecider.app = app;
  cliDecider.store = options.store || null;
  cliDecider.restricted = options.restricted || [];
  cliDecider.before = options.before || {};
  common.templateUsage(app, cliDecider.commands);

  app.commands['decider'] = app.commands['decider'] || {};
  app.commands['decider'] = common.mixin(app.commands['decider'], cliDecider.commands);
};

//
// ### function detach ()
// Detaches this plugin from the application.
//
cliDecider.detach = function () {
  var app = this;

  Object.keys(app.commands['decider']).forEach(function (method) {
    if (cliDecider.commands[method]) {
      delete app.commands['decider'][method];
    }

    cliDecider.commands.app = null;
  });
};