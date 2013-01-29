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
  var app, options, wfl, workflowOptions;

  wfl = require('../../lib/wfl');

  options = {
    domain: "demos",
    name: "transcoder"
  };

  app = wfl(options);

  workflowOptions = {
    my_id: "" + Math.random(),
    filename: "long-videos/AMZ_KND_RNV_ANTHEM_060_FRA_005_1024x576.mov",
    bucket: "pgt-misc"
  };

  app.start(workflowOptions);

}).call(this);
