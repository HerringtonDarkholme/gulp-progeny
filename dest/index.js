var depCache, fs, gutil, initParseConfig, makeFile, processedFileNames, progeny, sysPath, through;

gutil = require('gulp-util');

through = require('through2');

sysPath = require('path');

fs = require('fs');

progeny = require('./parse');

depCache = {};

processedFileNames = {};

makeFile = function(path, type, base, cwd) {
  var file;
  file = new gutil.File({
    base: base,
    cwd: cwd,
    path: path
  });
  if (type === 'stream') {
    file.contents = fs.createReadStream(path);
  } else {
    file.contents = fs.readFileSync(path);
  }
  return file;
};

initParseConfig = function(config) {
  var parser;
  parser = progeny(config);
  return function(path) {
    return parser(path).filter(fs.existsSync).forEach(function(dep) {
      if (depCache[dep] == null) {
        depCache[dep] = {};
      }
      return depCache[dep][path] = 1;
    });
  };
};

module.exports = function(config) {
  var getDeps;
  getDeps = initParseConfig(config);
  return through.obj(function(file, enc, cb) {
    var base, cache, childPath, cwd, deps, path, type, _i, _len, _ref;
    if (file.isNull()) {
      this.push(file);
      return cb();
    }
    path = file.path;
    type = (_ref = file.isStream()) != null ? _ref : {
      'stream': 'buffer'
    };
    cwd = file.cwd;
    base = file.base;
    this.push(file);
    getDeps(path);
    if (!processedFileNames[path]) {
      processedFileNames[path] = 1;
      return cb();
    }
    cache = (depCache[path] != null ? depCache[path] : depCache[path] = {});
    deps = Object.keys(cache).filter(fs.existsSync);
    cache = depCache[path] = {};
    for (_i = 0, _len = deps.length; _i < _len; _i++) {
      childPath = deps[_i];
      this.push(makeFile(childPath, type, base, cwd));
      cache[childPath] = 1;
    }
    return cb();
  });
};
