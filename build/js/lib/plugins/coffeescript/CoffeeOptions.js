var _, conf, configurable, rek;

_ = require('lodash');

rek = require('rekuire');

conf = rek('conf');

configurable = rek('configurable');

module.exports = function(f) {
  var opt;
  opt = configurable(f);
  return _.extend(opt, conf.get('plugin:coffeescript:options', {}));
};
