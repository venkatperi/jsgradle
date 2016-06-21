var Collection, ConventionContainer, prop, rek,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

prop = rek('prop');

Collection = rek('lib/common/Collection');

ConventionContainer = (function(superClass) {
  extend(ConventionContainer, superClass);

  function ConventionContainer() {
    return ConventionContainer.__super__.constructor.apply(this, arguments);
  }

  return ConventionContainer;

})(Collection);

module.exports = ConventionContainer;
