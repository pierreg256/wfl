// Generated by CoffeeScript 1.3.3
(function() {
  var Workflow, fs;

  fs = require('fs');

  Workflow = (function() {

    function Workflow(filename) {
      this.options = require(filename);
      console.log(this.options);
    }

    Workflow.prototype.setup = function() {
      return console.log("hey");
    };

    return Workflow;

  })();

  exports.Workflow = Workflow;

}).call(this);