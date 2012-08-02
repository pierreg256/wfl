var inspect = require('eyes').inspector();

var ActivityTask = exports.ActivityTask = function (swf, task) {
   this.swf = swf;
   this.task = task;
}


ActivityTask.prototype = {
   
   respondCompleted: function(result, callBack) {
      
      var _this = this;
      
      if(typeof result != "string") {
         result = JSON.stringify(result);
      }
      
      this.swf.RespondActivityTaskCompleted({
         "TaskToken": this.config.taskToken,
         "Result": result
      }, function(err, response) {
         
         if(err) {
            console.log("Error while sending RespondActivityTaskCompleted : ", err);
         }
         
         if(callBack) {
            callBack(err, response);
         }
         
      });
      
   },
   
   
   respondFailed: function() {
      // TODO
   }
   
};
