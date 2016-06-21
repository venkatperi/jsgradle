var Collection, SourceSetContainer, log, prop, rek,
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

rek = require('rekuire');

prop = rek('prop');

Collection = require('../common/Collection');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

SourceSetContainer = (function(superClass) {
  extend(SourceSetContainer, superClass);

  prop(SourceSetContainer, 'root', {
    get: function() {
      var root;
      root = this;
      while ((root.parent != null)) {
        root = root.parent;
      }
      return root;
    }
  });

  function SourceSetContainer(opts) {
    if (opts == null) {
      opts = {};
    }
    SourceSetContainer.__super__.constructor.call(this, opts);
    this.parent = opts.parent || (function() {
      throw new Error("Missing option: parent");
    })();
    this.on('add', (function(_this) {
      return function(name, obj) {
        _this._properties.exportedMethods.push(name);
        return _this[name] = function(f) {
          log.v("configuring " + name);
          if (Array.isArray(f)) {
            f = f[0];
          }
          if (f != null) {
            return _this.root.callScriptMethod(_this.get(name), f);
          }
        };
      };
    })(this));
  }

  return SourceSetContainer;

})(Collection);

module.exports = SourceSetContainer;
