var EventEmitter, Npm, npm,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty,
  slice = [].slice;

npm = require('npm');

EventEmitter = require('events').EventEmitter;

Npm = (function(superClass) {
  extend(Npm, superClass);

  function Npm() {
    this.install = bind(this.install, this);
    this.list = bind(this.list, this);
    this.cmd = bind(this.cmd, this);
    return Npm.__super__.constructor.apply(this, arguments);
  }

  Npm.prototype.cmd = function() {
    var args, conf, name;
    name = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    conf = {};
    return npm.load(conf, (function(_this) {
      return function(err) {
        var ref;
        console.log(err);
        return (ref = npm.commands)[name].apply(ref, args);
      };
    })(this));
  };

  Npm.prototype.list = function() {
    var conf;
    conf = {};
    return npm.load(conf, (function(_this) {
      return function(err) {
        var ls;
        if (err != null) {
          console.log(err);
        }
        ls = require('npm/lib/ls');
        return ls([], true, function(err, res) {
          return console.log(err, res);
        });
      };
    })(this));
  };

  Npm.prototype.install = function(pkg) {
    return npm;
  };

  return Npm;

})(EventEmitter);

new Npm().list();
