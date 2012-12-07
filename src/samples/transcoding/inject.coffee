wfl = require '../../lib/wfl'

options = 
	domain: "demos"
	name: "transcoder"

app = wfl(options)

workflowOptions = 
	my_id: ""+Math.random()
	filename:"long-videos/AMZ_KND_RNV_ANTHEM_060_FRA_005_1024x576.mov"
	bucket: "pgt-misc"

#setInterval ()->
app.start workflowOptions
#,5000
