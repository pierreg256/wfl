var inspect = require('eyes').inspector();

var DecisionTask = exports.DecisionTask = function (swf, task) {
	this.swf = swf;
	this.task = task;
}

DecisionTask.prototype = {
   
   respondCompleted: function(decisions, callBack) {
      
      var _this = this;

      inspect(_this, 'Decision Task');
      
      console.log(": RespondDecisionTaskCompleted... ");
      
      this.swf.RespondDecisionTaskCompleted({
        "TaskToken": _this.task.taskToken,
        "Decisions": decisions
      }, function(err, result) {
         inspect(err, 'erreur dans le complete');
         if(err) {
            //console.log(_this.config.identity+": RespondDecisionTaskCompleted error", err, result);
            if (callBack) {
            	callBack(err, null);
            	return;
            }
         }
         
        if (callBack) {
        	callBack(null, result);
        }
         
      });
      
   },
   
	CompleteWorkflowExecution: function(cb) {

      this.respondCompleted([
            {
                "decisionType":"CompleteWorkflowExecution",
                "CompleteWorkflowExecutionDecisionAttributes":{
                  "result": "Finished !"
                }
            }
        ], cb);
      
   	},
   
   respondFailed: function() {
      // TODO
   }
   
};
