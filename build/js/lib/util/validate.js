var _, ensureOptions,
  slice = [].slice;

_ = require('lodash');

ensureOptions = (function(_this) {
  return function() {
    var i, items, len, n, names, obj, ref;
    obj = arguments[0], names = 2 <= arguments.length ? slice.call(arguments, 1) : [];
    items = {};
    ref = _.flatten(names);
    for (i = 0, len = ref.length; i < len; i++) {
      n = ref[i];
      if ((obj != null ? obj[n] : void 0) == null) {
        throw new Error("Missing option: " + n);
      }
      items[n] = obj[n];
    }
    return items;
  };
})(this);

module.exports = {
  ensureOptions: ensureOptions
};
