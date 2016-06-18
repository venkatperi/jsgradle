var Q, glob;

Q = require('q');

glob = require('glob');

module.exports = Q.denodeify(glob);
