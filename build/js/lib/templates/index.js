var EventEmitter, Template, cache, conf, handlebars, path, readFileSync, ref, rek, writeFileMkdirSync,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

handlebars = require('handlebars');

rek = require('rekuire');

conf = rek('conf');

ref = rek('fileOps'), writeFileMkdirSync = ref.writeFileMkdirSync, readFileSync = ref.readFileSync;

cache = require('guava-cache');

path = require('path');

EventEmitter = require('events').EventEmitter;

Template = (function(superClass) {
  extend(Template, superClass);

  function Template(opts) {
    if (opts == null) {
      opts = {};
    }
    this.generate = bind(this.generate, this);
    this.render = bind(this.render, this);
    this.get = bind(this.get, this);
    this.load = bind(this.load, this);
    this.dir = opts.dir || __dirname;
    this.ext = opts.ext || 'hbr';
    this.cache = cache();
    this.cache.on('error', (function(_this) {
      return function(err) {
        return _this.emit('error', err);
      };
    })(this));
  }

  Template.prototype.load = function(name) {
    var contents;
    contents = readFileSync(path.join(this.dir, name + "." + this.ext), 'utf8');
    return handlebars.compile(contents);
  };

  Template.prototype.get = function(name) {
    return this.cache.get(name, this.load);
  };

  Template.prototype.render = function(name, context) {
    return this.get(name)(context);
  };

  Template.prototype.generate = function(name, context, outPath) {
    return writeFileMkdirSync(outPath, this.render(name, context));
  };

  return Template;

})(EventEmitter);

module.exports = Template;
