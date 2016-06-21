var _, configurable, log, rek, util,
  hasProp = {}.hasOwnProperty;

util = require('util');

_ = require('lodash');

rek = require('rekuire');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

configurable = function(obj, invoker) {
  var handlers, k, properties, ref, v, wrap;
  wrap = function(value) {
    if (!_.isObjectLike(value)) {
      return value;
    }
    return configurable(value, invoker);
  };
  handlers = {
    get: function(target, name) {
      switch (name) {
        case 'hasProperty':
          return function(x) {
            return true;
          };
        case 'hasMethod':
          return function(x) {
            return x != null;
          };
        case 'getProperty':
          return function(x) {
            var v;
            v = target[x];
            if (!_.isObjectLike(v)) {
              return v;
            } else {
              return x;
            }
          };
        case 'setProperty':
          return function(k, v) {
            return target[k] = v;
          };
        case 'getMethod':
          return function(x) {
            return function(fn) {
              if ((fn != null ? fn.type : void 0) === 'function' && (invoker != null)) {
                if (target[x] == null) {
                  target[x] = configurable({}, invoker);
                }
                return invoker(target[x], fn);
              }
            };
          };
        default:
          return target[name];
      }
    },
    set: function(target, name, value) {
      return target[name] = wrap(value);
    }
  };
  if (arguments.length === 1) {
    if (typeof obj === 'function') {
      ref = [obj], invoker = ref[0], obj = ref[1];
    }
  }
  properties = {};
  for (k in obj) {
    if (!hasProp.call(obj, k)) continue;
    v = obj[k];
    properties[k] = wrap(k, v);
  }
  return new Proxy(properties, handlers);
};

module.exports = configurable;
