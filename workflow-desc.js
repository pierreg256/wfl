
exports = {
	"domain": "my-domain",
	"name": "my_workflow",

	"decider": {
		"name" : "my-workflow-decider",
		"routes": [
			{
				"route": "/start",
				"activity": function (request, response) {
					response.startActivity("say-hello");
				}
			},

			{
				"route": "/start/say-hello",
				"activity": function (request, response) {
					response.startActivity("say-world", request.inputValue);
				}
			}
		]
	},

	"activities": [
		{
			"name": "say-hello",
			"activity": function(request, response) {
				var myResult = {valule:"toto", label:"je ne sais pas"};
				response.send(myResult);	
			}
		},

		{
			"name": "say-world",
			"activity": function(request, response) {
				var myResult = {valule:"toto", label:"je ne sais pas"};
				response.send(myResult);	
			}
		}	
	]
};

