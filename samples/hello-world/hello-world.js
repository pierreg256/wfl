// Generated by CoffeeScript 1.3.3

/* 
THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/


(function() {
  var app, inspect, options, wfl;

  wfl = require('../../lib/wfl');

  inspect = require('eyes').inspector();

  options = {
    domain: "demos",
    name: "hello-world"
  };

  app = wfl(options);

  app.useActivity("checkName", function(request, response) {
    app.logger.debug("" + request.id + " - got name: " + request.input.name + "}");
    inspect(request.input, "input params");
    if ((request.input != null) && request.input.length > 0) {
      return response.send({
        status: "OK",
        message: "got name: " + request.input,
        name: request.input.name
      });
    } else {
      return response.send({
        status: "NOK",
        error: {
          message: "no name found in the input parameters",
          code: 404
        }
      });
    }
  });

  app.useActivity("sayHello", function(request, response) {
    var reply;
    reply = "Hello, " + request.input + "!";
    app.logger.debug("" + request.id + " - will answer : " + reply);
    return response.send({
      status: "OK",
      message: reply
    });
  });

  app.makeDecision("/start", function(request, response) {
    return response.scheduleActivity("checkName", request.input);
  });

  app.makeDecision("/start/checkName", function(request, response) {
    if (request.task.result.status === "OK") {
      return response.scheduleActivity("sayHello", request.input);
    } else {
      return response.cancel("Activity " + request.task.id + " responded in error: " + request.task.result.error.code + " - " + request.task.result.error.message);
    }
  });

  app.makeDecision("/start/checkName/sayHello", function(request, response) {
    return response.end(request.task.result.message);
  });

  app.listen();

}).call(this);
