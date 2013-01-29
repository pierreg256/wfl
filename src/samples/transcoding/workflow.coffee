### 
THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR 
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER 
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
###

wfl = require '../../lib/wfl'
inspect = require('eyes').inspector()
myDecisions = require './decisions'

AWS = require 'aws-sdk'

awsCfg = 
    'accessKeyId' : process.env.AWS_ACCESS_KEY
    'secretAccessKey' : process.env.AWS_SECRET_KEY

AWS.config.update(awsCfg);
S3 = new AWS.S3 
s3client = S3.client 


options = 
	domain: "demos"
	name: "transcoder"

app = wfl(options)

app.useActivity "checkVideo", (request, response)->
	app.logger.verbose "#{request.id} - Checking video: #{request.input.bucket}/#{request.input.filename}"
	req = s3client.headObject({Bucket: request.input.bucket, Key:request.input.filename})
	req.done (resp)->
		response.send {status: "OK", message:"Found Video in S3", size:resp.data.ContentLength}
	req.fail (resp)->
		response.send {status: "NOK", message:"Video not found in S3", error:resp.error}

app.useActivity "shortenVideo", (request, response)->
	app.logger.verbose "#{request.id} - Shortening video: #{request.input.url}"
	response.send {status: "OK", message:"Video Shortened successfully"}

app.useActivity "catCheck", (request, response)->
	app.logger.verbose "#{request.id} - Checking video: #{request.input.url} for cats"
	response.send {status: "OK", message:"Clean Video", cats:false}

app.useActivity "rejectVideo", (request, response)->
	app.logger.verbose "#{request.id} - Rejected video: #{request.input.url}. sending email to the user"
	response.send {status: "OK", message:"Video Rejected"}

app.useActivity "transcodeVideo", (request, response)->
	app.logger.verbose "#{request.id} - Transcoding video: #{request.input.url}."
	response.send {status: "OK", message:"Transcoded to format H264/AAC"}

app.useActivity "publishVideo", (request, response)->
	app.logger.verbose "#{request.id} - Publishing video: #{request.input.url}. sending email to the user"
	response.send {status: "OK", message:"Video Published"}

app.makeDecision "/start", (request, response)->
	app.logger.verbose "Sceduling activity checkVideo"
	response.scheduleActivity "checkVideo", request.input

app.makeDecision "/start/checkVideo", myDecisions.videoChecked

app.makeDecision "/start/checkVideo/catCheck", myDecisions.catChecked
app.makeDecision "/start/checkVideo/catCheck/transcodeVideo", myDecisions.videoTranscoded
app.makeDecision "/start/checkVideo/catCheck/transcodeVideo/publishVideo", myDecisions.videoPublished

app.makeDecision "/start/checkVideo/shortenVideo", myDecisions.videoShortened
app.makeDecision "/start/checkVideo/shortenVideo/catCheck", myDecisions.catChecked
app.makeDecision "/start/checkVideo/shortenVideo/catCheck/transcodeVideo", myDecisions.videoTranscoded
app.makeDecision "/start/checkVideo/shortenVideo/catCheck/transcodeVideo/publishVideo", myDecisions.videoPublished


app.listen()
