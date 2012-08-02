/*
 * flatiron-cli-domain.js: Top-level include for the `flatiron-cli-domain` module.
 *
 * (C) 2010, Nodejitsu Inc.
 *
 */

var common = require('flatiron').common;

var cliDomain = exports;

//
// Expose commands and name this plugin
//
cliDomain.commands = require('./commands');
cliDomain.name = 'cli-domain';

//
// ### function attach (options)
// #### @options {Object} Options to use when attaching
// Attaches the `flatiron-cli-domain` behavior to the application.
//
cliDomain.attach = function (options) {
  var app = this;
  options = options || {};

  if (!app.plugins.cli) {
    throw new Error('`cli` plugin is required to use `cli-domain`');
  }
  else if (!app.config) {
    throw new Error('`app.config` must be set to use `cli-domain`');
  }

  app.config.remove('literal');
  cliDomain.app = app;
  cliDomain.store = options.store || null;
  cliDomain.restricted = options.restricted || [];
  cliDomain.before = options.before || {};
  common.templateUsage(app, cliDomain.commands);

  app.commands['domain'] = app.commands['domain'] || {};
  app.commands['domain'] = common.mixin(app.commands['domain'], cliDomain.commands);
  app.alias('dom', { resource: 'domain', command: 'list' });
};

//
// ### function detach ()
// Detaches this plugin from the application.
//
cliDomain.detach = function () {
  var app = this;

  Object.keys(app.commands['domain']).forEach(function (method) {
    if (cliDomain.commands[method]) {
      delete app.commands['domain'][method];
    }

    cliDomain.commands.app = null;
  });
};