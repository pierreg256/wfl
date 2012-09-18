// Generated by CoffeeScript 1.3.3
(function() {
  var Application, DecisionResponse, Swf, amazon, awssum, createApplication, inspect, _checkActivity, _checkDomain, _checkWorkflow, _makeRoute;

  inspect = require('eyes').inspector();

  awssum = require('awssum');

  amazon = awssum.load('amazon/amazon');

  Swf = awssum.load('amazon/swf').Swf;

  DecisionResponse = require("./models/DecisionResponse").DecisionResponse;

  createApplication = function(options) {
    var app;
    app = new Application(options);
    return app;
  };

  Application = (function() {

    function Application(options) {
      var swfCfg, winston, _base, _base1, _base2, _base3, _base4, _base5, _base6, _base7, _base8, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8,
        _this = this;
      if (options == null) {
        options = {};
      }
      this.options = options;
      if ((_ref = (_base = this.options).force) == null) {
        _base.force = false;
      }
      if ((_ref1 = (_base1 = this.options).accessKeyId) == null) {
        _base1.accessKeyId = "BAD_KEY";
      }
      if ((_ref2 = (_base2 = this.options).secretAccessKey) == null) {
        _base2.secretAccessKey = "BAD_SECRET_KEY";
      }
      if ((_ref3 = (_base3 = this.options).region) == null) {
        _base3.region = "us-east-1";
      }
      if ((_ref4 = (_base4 = this.options).domain) == null) {
        _base4.domain = "sample-domain";
      }
      if ((_ref5 = (_base5 = this.options).name) == null) {
        _base5.name = "sample-workflow";
      }
      if ((_ref6 = (_base6 = this.options).decider) == null) {
        _base6.decider = {};
      }
      if ((_ref7 = (_base7 = this.options.decider).name) == null) {
        _base7.name = "" + this.options.domain + "-" + this.options.name + "-decider";
      }
      if ((_ref8 = (_base8 = this.options.decider).taskList) == null) {
        _base8.taskList = function() {
          return "" + _this.options.domain + "-" + _this.options.name + "-decider-default-tasklist";
        };
      }
      this.options.decider.routes = [];
      this.options.activities = [];
      this.configStatus = 0;
      swfCfg = {
        'accessKeyId': this.options.accessKeyId,
        'secretAccessKey': this.options.secretAccessKey,
        'region': this.options.region
      };
      this.swf = new Swf(swfCfg);
      winston = require('winston');
      this.logger = new winston.Logger({
        transports: [
          new winston.transports.Console({
            'colorize': true
          })
        ]
      });
    }

    Application.prototype.useActivity = function(name, activityFn) {
      return this.options.activities.push({
        "name": name,
        "taskList": "" + name + "-default-tasklist",
        "activityTask": activityFn
      });
    };

    Application.prototype.makeDecision = function(route, decisionFn) {
      return this.options.decider.routes.push({
        "route": route,
        "decisionTask": decisionFn
      });
    };

    Application.prototype.start = function(inputValue) {
      var _this = this;
      return this._checkConfig(function() {
        var swfCfg;
        if (inputValue == null) {
          inputValue = "";
        }
        if (typeof inputValue !== "string") {
          inputValue = "" + JSON.stringify(inputValue);
        }
        swfCfg = {
          "Domain": _this.options.domain,
          "WorkflowId": _this.options.name + "-" + ((Math.random() + "").substr(2)),
          "WorkflowType": {
            "name": _this.options.name,
            "version": "1.0"
          },
          "Input": inputValue
        };
        return _this.swf.StartWorkflowExecution(swfCfg, function(err, data) {
          if (err != null) {
            _this.logger.error("Unexpected error starting workflow", err);
          }
          if (data != null) {
            return _this.logger.info("Started workflow execution with the following id: " + swfCfg.WorkflowId);
          }
        });
      });
    };

    Application.prototype.listen = function() {
      var _this = this;
      return this._checkConfig(function() {
        return _this._startListeners();
      });
    };

    Application.prototype._checkConfig = function(callBack) {
      var _ref,
        _this = this;
      if ((_ref = this.configStatus) == null) {
        this.configStatus = 0;
      }
      if (this.configStatus === 2) {
        return callBack();
      }
      if (this.configStatus === 1) {
        return setTimeout(function() {
          return _this._checkConfig(callBack);
        }, 1000);
      }
      if (this.configStatus === 0) {
        this.configStatus = 1;
        this.logger.info("Checking config, please wait...");
        return _checkDomain(this.swf, this.options.domain, this.options.force, function(err, data) {
          if (err != null) {
            _this.configStatus = 0;
            return _this.logger.error(err.message, err.context);
          } else {
            _this.logger.info("Domain " + _this.options.domain + " checked!");
            return _checkWorkflow(_this.swf, _this.options.domain, _this.options.name, _this.options.decider.taskList(), _this.options.force, function(errD, dataD) {
              var func, i;
              if (errD != null) {
                _this.configStatus = 0;
                return _this.logger.error(errD.message, errD.context);
              } else {
                _this.logger.info("Workflow " + _this.options.name + " checked!");
                func = function(e, d) {
                  if (e != null) {
                    _this.configStatus = 0;
                    return _this.logger.error(e.message, e.context);
                  } else {
                    i++;
                    if (i > 0) {
                      _this.logger.info("Activity " + _this.options.activities[i - 1].name + " checked!");
                    }
                    if (_this.options.activities[i] != null) {
                      return _checkActivity(_this.swf, _this.options.domain, _this.options.activities[i].name, _this.options.activities[i].taskList, _this.options.force, func);
                    } else {
                      _this.configStatus = 2;
                      return callBack();
                    }
                  }
                };
                i = -1;
                return func();
              }
            });
          }
        });
      }
    };

    Application.prototype._startListeners = function() {
      var activ;
      this.logger.info("Workflow application " + this.options.domain + "/" + this.options.name + " listening...");
      for (activ in this.options.activities) {
        this._listenForActivity(this.options.activities[activ].name, this.options.activities[activ].taskList);
      }
      return this._listen();
    };

    Application.prototype._listenForActivity = function(name, taskList) {
      var swfCfg,
        _this = this;
      this.logger.info("Polling for next activity task (" + taskList + ")");
      swfCfg = {
        'Domain': this.options.domain,
        'TaskList': {
          "name": taskList
        }
      };
      return this.swf.PollForActivityTask(swfCfg, function(err, data) {
        var body, token;
        if (err != null) {
          _this.logger.error("Unexpected Error", err);
        } else {
          body = data.Body;
          token = body.taskToken;
          if (!(token != null)) {
            _this.logger.info("No activity task in the pipe for " + taskList + ", repolling...");
            process.nextTick(function() {
              return _this.poll();
            });
          } else {
            inspect(data, "activity Data");
          }
        }
        return process.nextTick(function() {
          return _this._listenForActivity(name, taskList);
        });
      });
    };

    Application.prototype._listen = function() {
      var swfCfg,
        _this = this;
      this.logger.info("Polling for next decision task (tasklist: " + (this.options.decider.taskList()) + ")");
      swfCfg = {
        'Domain': this.options.domain,
        'TaskList': {
          'name': "" + (this.options.decider.taskList())
        }
      };
      return this.swf.PollForDecisionTask(swfCfg, function(err, data) {
        var body, token;
        if (err != null) {
          _this.logger.error("Error polling decision task", err);
        } else {
          body = data.Body;
          token = body.taskToken;
          if (token != null) {
            _this.logger.info("New decision task received");
            _makeRoute(body.events, function(routeError, request) {
              var response, tmpRoute, _results;
              response = new DecisionResponse(_this, token);
              _results = [];
              for (tmpRoute in _this.options.decider.routes) {
                _results.push(_this.options.decider.routes[tmpRoute].route === request.url ? (_this.logger.debug("Making following decision: " + _this.options.decider.routes[tmpRoute].route), _this.options.decider.routes[tmpRoute].decisionTask(request, response)) : _this.logger.debug("" + _this.options.decider.routes[tmpRoute].route + " is not " + request.url));
              }
              return _results;
            });
          }
        }
        return process.nextTick(function() {
          return _this._listen();
        });
      });
    };

    return Application;

  })();

  _makeRoute = function(events, callBack) {
    var event, handled, request, response, route, _ref;
    if (events == null) {
      events = [];
    }
    request = {};
    response = {};
    route = "";
    for (event in events) {
      handled = false;
      if (events[event].eventType === "WorkflowExecutionStarted") {
        handled = true;
        if (route.indexOf("/start") < 0) {
          route += "/start";
          request = {
            workFlow: {
              name: events[event].workflowExecutionStartedEventAttributes.workflowType.name,
              version: events[event].workflowExecutionStartedEventAttributes.workflowType.version,
              input: ""
            },
            decisionTask: {
              name: "",
              status: "NONE"
            }
          };
          try {
            request.workFlow.input = JSON.parse(events[event].workflowExecutionStartedEventAttributes.input);
          } catch (e) {
            request.workFlow.input = (_ref = events[event].workflowExecutionStartedEventAttributes.input) != null ? _ref : {};
          }
        }
      }
      if (events[event].eventType === "DecisionTaskScheduled") {
        handled = true;
        request.decisionTask.name = events[event].decisionTaskScheduledEventAttributes.taskList.name;
        request.decisionTask.status = "SCHEDULED";
      }
      if (events[event].eventType === "DecisionTaskStarted") {
        handled = true;
        request.decisionTask.status = "STARTED";
      }
      if (events[event].eventType === "DecisionTaskTimedOut") {
        handled = true;
        request.decisionTask.status = "TIMED_OUT";
      }
      if (handled !== true) {
        inspect(events[event], "Evenement " + events[event].name);
        throw "Unhandled event type : " + events[event].eventType;
      }
    }
    request.url = route;
    return callBack(null, request);
  };

  _checkDomain = function(swf, domainName, force, callBack) {
    var swfParams,
      _this = this;
    if (force == null) {
      force = false;
    }
    swfParams = {
      Name: domainName
    };
    return swf.DescribeDomain(swfParams, function(descDomainErr, descDomainData) {
      if (descDomainErr != null) {
        if ((descDomainErr.Body != null) && (descDomainErr.Body.__type != null) && descDomainErr.Body.__type.indexOf("UnknownResourceFault") > -1) {
          if (!force) {
            return callBack({
              err: "NO_DOMAIN",
              message: "Domain " + domainName + " doesnt exist. Please use the force option to create it."
            });
          } else {
            swfParams = {
              'Name': domainName,
              'WorkflowExecutionRetentionPeriodInDays': '1'
            };
            return swf.RegisterDomain(swfParams, function(regDomainErr, regDomainData) {
              if (regDomainErr != null) {
                return callBack({
                  err: "UNEXPECTED",
                  message: "Unexpected error encountered",
                  context: regDomainErr
                });
              } else {
                return callBack(null, domainName);
              }
            });
          }
        } else {
          return callBack({
            err: "UNEXPECTED",
            message: "Unexpected error encountered",
            context: descDomainErr
          });
        }
      } else {
        return callBack(null, domainName);
      }
    });
  };

  _checkWorkflow = function(swf, domainName, workflowName, taskList, force, callBack) {
    var swfParams,
      _this = this;
    if (force == null) {
      force = false;
    }
    swfParams = {
      Domain: domainName,
      WorkflowType: {
        name: workflowName,
        version: "1.0"
      }
    };
    return swf.DescribeWorkflowType(swfParams, function(descWflErr, descWflData) {
      if (descWflErr != null) {
        if ((descWflErr.Body != null) && (descWflErr.Body.__type != null) && descWflErr.Body.__type.indexOf("UnknownResourceFault") > -1) {
          if (!force) {
            return callBack({
              err: "NO_WORKFLOW",
              message: "Workflow " + domainName + "/" + workflowName + " doesnt exist. Please use the force option to create it."
            });
          } else {
            swfParams = {
              "Domain": domainName,
              "Name": workflowName,
              "Version": "1.0",
              "Description": "Automatically created workflow type.",
              "DefaultTaskStartToCloseTimeout": "600",
              "DefaultExecutionStartToCloseTimeout": "3600",
              "DefaultTaskList": {
                "name": "" + taskList
              },
              "DefaultChildPolicy": "TERMINATE"
            };
            return swf.RegisterWorkflowType(swfParams, function(regWflErr, regWflData) {
              if (regWflErr != null) {
                return callBack({
                  err: "UNEXPECTED",
                  message: "Unexpected error encountered",
                  context: regWflErr
                });
              } else {
                return callBack(null, workflowName);
              }
            });
          }
        } else {
          return callBack({
            err: "UNEXPECTED",
            message: "Unexpected error encountered",
            context: descWflErr
          });
        }
      } else {
        return callBack(null, workflowName);
      }
    });
  };

  _checkActivity = function(swf, domainName, activityName, taskList, force, callBack) {
    var swfParams,
      _this = this;
    if (force == null) {
      force = false;
    }
    swfParams = {
      Domain: domainName,
      ActivityType: {
        name: activityName,
        version: "1.0"
      }
    };
    return swf.DescribeActivityType(swfParams, function(descActErr, descActData) {
      if (descActErr != null) {
        if ((descActErr.Body != null) && (descActErr.Body.__type != null) && descActErr.Body.__type.indexOf("UnknownResourceFault") > -1) {
          if (!force) {
            return callBack({
              err: "NO_ACTIVITY",
              message: "Activity " + domainName + "/" + activityName + " doesnt exist. Please use the force option to create it."
            });
          } else {
            swfParams = {
              "Domain": domainName,
              "Name": activityName,
              "Version": "1.0",
              "Description": "Automatically created activity type",
              "DefaultTaskStartToCloseTimeout": "600",
              "DefaultTaskHeartbeatTimeout": "120",
              "DefaultTaskList": {
                "name": taskList
              },
              "DefaultTaskScheduleToStartTimeout": "300",
              "DefaultTaskScheduleToCloseTimeout": "900"
            };
            return swf.RegisterActivityType(swfParams, function(regActErr, regActData) {
              if (regActErr != null) {
                return callBack({
                  err: "UNEXPECTED",
                  message: "Unexpected error encountered",
                  context: regActErr
                });
              } else {
                return callBack(null, activityName);
              }
            });
          }
        } else {
          return callBack({
            err: "UNEXPECTED",
            message: "Unexpected error encountered",
            context: descActErr
          });
        }
      } else {
        return callBack(null, activityName);
      }
    });
  };

  module.exports = createApplication;

}).call(this);