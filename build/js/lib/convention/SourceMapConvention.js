var CompileConvention, SourceMapConvention, SourceSetContainer, SourceSetOutput, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

CompileConvention = rek('CompileConvention');

SourceSetContainer = rek('SourceSetContainer');

SourceSetOutput = rek('SourceSetOutput');

SourceMapConvention = (function(superClass) {
  extend(SourceMapConvention, superClass);

  function SourceMapConvention() {
    this.createSourceSets = bind(this.createSourceSets, this);
    return SourceMapConvention.__super__.constructor.apply(this, arguments);
  }

  SourceMapConvention.prototype.createSourceSets = function() {
    var output;
    SourceMapConvention.__super__.createSourceSets.call(this);
    if (!this.sourceSetExists('main.sourceMap')) {
      output = this.getSourceSet('main.output').dir;
      return this.createSourceSet('main.sourceMap', SourceSetOutput, {
        dir: output + "/maps"
      });
    }
  };

  return SourceMapConvention;

})(CompileConvention);

module.exports = SourceMapConvention;
