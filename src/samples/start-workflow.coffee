wfl = require '../lib/wfl'

options = 
	domain: "wfl-dev-2"

app = wfl(options)

workflowOptions = 
	my_id: ""+Math.random()
	name:"toto"
	filePath:"/dev/null"

app.start workflowOptions
