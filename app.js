var flatiron = require('flatiron'),
    path = require('path'),
    app = flatiron.app;

app.awssum = require('awssum');
app.amazon = app.awssum.load('amazon/amazon');
app.Swf = app.awssum.load('amazon/swf').Swf;


app.config.file({ file: path.join(__dirname, 'config', 'config.json') });



app.use(flatiron.plugins.cli, {
  source: path.join(__dirname, 'lib', 'commands'),
  usage: 'Simple Workflow Manager...',
  version: true,
  argv: {
    secretAccessKey: {
      alias: 's',
      description: 'your AWS secret key',
      string: true
    },
    accessKeyId: {
      alias: 'k',
      description: 'your AWS access key',
      string: true
    }
  }
});
app.use(require('flatiron-cli-config'));
app.use(require('./lib/plugins/domain/cli-domain'));
app.use(require('./lib/plugins/workflow/cli-workflow'));
app.use(require('./lib/plugins/activity/cli-activity'));
app.version = true;

//app.start();
module.exports = app;
