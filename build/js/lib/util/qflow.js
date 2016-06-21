var Q, find, q;

q = require('q');


/**
 * Call `fn`, which returns a promise, on each item in `array`.
 */

Q = {};

Q.each = function(array, fn) {
  return array.reduce((function(promise, each) {
    return promise.then(function() {
      return fn(each);
    });
  }), q()).then(function() {});
};


/**
 * Call `fn`, which returns a promise, on each item in `array`, returning new
 * array.
 */

Q.map = function(array, fn) {
  var mappedArray;
  mappedArray = [];
  q.each(array, (function(each) {
    return fn(each).then(function(item) {
      mappedArray.push(item);
    });
  }), q()).then(function() {
    return mappedArray;
  });
};

find = function(array, fn, current) {
  return Q.until(function() {
    return fn(array[current]).then(function(result) {
      if (result) {
        return array[current];
      }
      current += 1;
      if (current >= array.length) {
        return true;
      }
    });
  });
};


/**
 * Find first object in `array` satisfying the condition returned by the
 * promise returned by `fn`.
 */

Q.find = function(array, fn) {
  return find(array, fn, 0).then(function(result) {
    if (result === true) {
      return void 0;
    }
    return result;
  });
};


/**
 * Loop until the promise returned by `fn` returns a truthy value.
 */

Q.until = function(fn) {
  return fn().then(function(result) {
    if (result) {
      return result;
    }
    return Q.until(fn);
  });
};

module.exports = Q;
