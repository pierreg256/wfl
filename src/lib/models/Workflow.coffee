fs = require 'fs'

class Workflow 
	constructor: (filename) ->
		@options = require filename #fs.readFileSync(filename, 'UTF8');
		#@options = JSON.parse @strOptions
		console.log @options

	setup: () ->
		console.log "hey"

exports.Workflow = Workflow
