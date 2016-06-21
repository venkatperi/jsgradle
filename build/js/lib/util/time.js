var HrTime, Q, time,
  slice = [].slice;

Q = require('q');

HrTime = require('./HrTime');

time = function() {
  var args, f, t;
  f = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
  t = new HrTime();
  return Q["try"](function() {
    return f.apply.apply(f, [null].concat(slice.call(args)));
  }).then(function(res) {
    t.mark();
    return [res, t];
  });
};

module.exports = time;
