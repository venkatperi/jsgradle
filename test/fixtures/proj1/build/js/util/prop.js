module.exports = function(obj, name, config) {
  return Object.defineProperty(obj.prototype, name, config);
};
