var BaseFactory, FilesSpec, FilesSpecFactory, log, rek,
  bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
  hasProp = {}.hasOwnProperty;

BaseFactory = require('./BaseFactory');

rek = require('rekuire');

log = rek('logger')(require('path').basename(__filename).split('.')[0]);

FilesSpec = rek('FilesSpec');

FilesSpecFactory = (function(superClass) {
  extend(FilesSpecFactory, superClass);

  function FilesSpecFactory() {
    this.newInstance = bind(this.newInstance, this);
    return FilesSpecFactory.__super__.constructor.apply(this, arguments);
  }

  FilesSpecFactory.prototype.newInstance = function(builder, name, value, args) {
    var opts;
    log.v('newInstance');
    opts = {};
    switch (name) {
      case 'from':
        opts.srcDir = value;
        break;
      case 'into':
        opts.dest = value;
        break;
      case 'filter':
        opts.filter = value;
    }
    return new FilesSpec(opts);
  };

  return FilesSpecFactory;

})(BaseFactory);

module.exports = FilesSpecFactory;
