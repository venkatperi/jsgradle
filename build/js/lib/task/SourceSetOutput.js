var Collection, SourceSetOutput, path, rek,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

path = require('path');

rek = require('rekuire');

Collection = rek('Collection');

SourceSetOutput = (function(superClass) {
  extend(SourceSetOutput, superClass);

  function SourceSetOutput() {
    return SourceSetOutput.__super__.constructor.apply(this, arguments);
  }

  SourceSetOutput._addProperties({
    required: ['dir'],
    optional: ['parent'],
    exported: ['dir']
  });

  return SourceSetOutput;

})(Collection);

module.exports = SourceSetOutput;
