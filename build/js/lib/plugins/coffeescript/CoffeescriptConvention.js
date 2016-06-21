var CoffeescriptConvention, SourceMapConvention, SourceSetContainer, SourceSetOutput, _conf, rek,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

SourceMapConvention = rek('SourceMapConvention');

_conf = rek('conf');

SourceSetContainer = rek('SourceSetContainer');

SourceSetOutput = rek('SourceSetOutput');

CoffeescriptConvention = (function(superClass) {
  extend(CoffeescriptConvention, superClass);

  function CoffeescriptConvention() {
    return CoffeescriptConvention.__super__.constructor.apply(this, arguments);
  }

  return CoffeescriptConvention;

})(SourceMapConvention);

module.exports = CoffeescriptConvention;
