var inspect = require('eyes').inspector();

var start = module.exports = function start(vars, callback) {
  console.log('salut!');
  inspect(vars, 'vars');
  inspect(this, 'this');
}
start.usage = 'start --name <workflow-type> --domain <workflow-domain>';
start.argv = {name: {alias: 'n', description:'workflow-type-name'}};

