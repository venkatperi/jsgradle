var CompileConvention, Convention, FilesSpec, SourceSetContainer, SourceSetOutput, _, _conf, assert, log, rek, sourceSet,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

_ = require('lodash');

rek = require('rekuire');

Convention = rek('Convention');

_conf = rek('conf');

SourceSetContainer = rek('SourceSetContainer');

SourceSetOutput = rek('SourceSetOutput');

FilesSpec = rek('FilesSpec');

assert = require('assert');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

sourceSet = function(name) {
  name = 'sourceSets:' + name.replace(/\./g, ':');
  return _conf.get(name);
};

CompileConvention = (function(superClass) {
  extend(CompileConvention, superClass);

  function CompileConvention() {
    this.createSourceSets = bind(this.createSourceSets, this);
    return CompileConvention.__super__.constructor.apply(this, arguments);
  }

  CompileConvention.prototype.createSourceSets = function() {
    var defaultKey, i, key, len, opts, ref, results, x;
    ref = ['main', 'test'];
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      x = ref[i];
      if (!this.sourceSetExists(x)) {
        this.createSourceSet(x, SourceSetContainer);
      }
      assert(this.sourceSetExists(x));
      defaultKey = x + ".default";
      key = x + "." + this.name;
      if (!this.sourceSetExists(key)) {
        opts = sourceSet(key) || sourceSet(defaultKey);
        opts = _.extend(opts, {
          allMethods: true,
          name: this.name
        });
        this.createSourceSet(key, FilesSpec, opts);
      }
      key = x + ".output";
      if (!this.sourceSetExists(key)) {
        opts = sourceSet(key) || {
          dir: this.project.buildDir
        };
        this.createSourceSet(key, SourceSetOutput, opts);
      }
      defaultKey = x + ".output.default";
      key = x + ".output." + this.name;
      if (!this.sourceSetExists(key)) {
        opts = sourceSet(key) || sourceSet(defaultKey) || {};
        if (opts.dir == null) {
          opts.dir = '.';
        }
        results.push(this.createSourceSet(key, SourceSetOutput, opts));
      } else {
        results.push(void 0);
      }
    }
    return results;
  };

  module.exports = CompileConvention;

  return CompileConvention;

})(Convention);
