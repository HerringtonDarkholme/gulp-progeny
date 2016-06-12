var depCache, fs, gutil, initParseConfig, makeFile, processedFileNames, progeny, pushFileRecursive, sysPath, through;

gutil = require('gulp-util');

through = require('through2');

sysPath = require('path');

fs = require('fs');

progeny = require('progeny');

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
  return function(path, cb) {
    Object.keys(depCache).forEach(function(key) {
      if (path in depCache[key]) {
        return delete depCache[key][path];
      }
    });
    return parser(path, function(err, deps) {
      deps = deps.filter(fs.existsSync);
      deps.forEach(function(dep) {
        if (depCache[dep] == null) {
          depCache[dep] = {};
        }
        return depCache[dep][path] = 1;
      });
      return cb();
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
    var base, cwd, onDepsParsed, path, ref, self, type;
    self = this;
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
    onDepsParsed = function() {
      var childPath, fileSet;
      if (!processedFileNames[path]) {
        processedFileNames[path] = 1;
        return cb();
      }
      fileSet = {};
      pushFileRecursive(fileSet, path);
      for (childPath in fileSet) {
        self.push(makeFile(childPath, type, base, cwd));
      }
      return cb();
    };
    return getDeps(path, onDepsParsed);
  });
};
