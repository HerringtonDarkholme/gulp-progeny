var depCache, fs, gutil, initParseConfig, makeFile, processedFileNames, progeny, pushFileRecursive, sysPath, through;

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
    path: path,
    stat: fs.statSync(path)
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
    Object.keys(depCache).forEach(function(key) {
      if (path in depCache[key]) {
        return delete depCache[key][path];
      }
    });
    return parser(path, true).filter(fs.existsSync).forEach(function(dep) {
      if (depCache[dep] == null) {
        depCache[dep] = {};
      }
      return depCache[dep][path] = 1;
    });
  };
};

pushFileRecursive = function(fileSet, path) {
  var cache, childPath, results;
  cache = (depCache[path] != null ? depCache[path] : depCache[path] = {});
  results = [];
  for (childPath in cache) {
    if (!fs.existsSync(childPath)) {
      results.push(delete cache[childPath]);
    } else {
      fileSet[childPath] = 1;
      results.push(pushFileRecursive(fileSet, childPath));
    }
  }
  return results;
};

module.exports = function(config) {
  var getDeps;
  getDeps = initParseConfig(config);
  return through.obj(function(file, enc, cb) {
    var base, childPath, cwd, fileSet, path, ref, type;
    if (file.isNull()) {
      this.push(file);
      return cb();
    }
    path = file.path;
    type = (ref = file.isStream()) != null ? ref : {
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
    fileSet = {};
    pushFileRecursive(fileSet, path);
    for (childPath in fileSet) {
      this.push(makeFile(childPath, type, base, cwd));
    }
    return cb();
  });
};
