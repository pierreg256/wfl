wfl = require '../../lib/wfl'

options = 
	domain: "demos"
	name: "transcoder"

app = wfl(options)

workflowOptions = 
	my_id: ""+Math.random()
	fileName:"toto"
	url:"https://s3-eu-west-1.amazonaws.com/monbucketeu/Bref.S01E05.FRENCH.DVDRiP.XViD-HTO.avi"

#setInterval ()->
app.start workflowOptions
#,5000
