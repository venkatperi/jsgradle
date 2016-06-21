module.exports = function(src, filename) {
  var m;
  m = new module.constructor;
  m.paths = module.paths;
  m._compile(src, filename);
  return m.exports;
};
