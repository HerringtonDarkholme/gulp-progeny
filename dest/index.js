var fs, gulpProgeny, gutil, initParseConfig, makeFile, progeny, pushFileRecursive, sysPath, through;

gutil = require('gulp-util');

through = require('through2');

sysPath = require('path');

fs = require('fs');

progeny = require('progeny');

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
    Object.keys(gulpProgeny.caches).forEach(function(key) {
      if (path in gulpProgeny.caches[key]) {
        return delete gulpProgeny.caches[key][path];
      }
    });
    return parser(path, function(err, deps) {
      deps = deps.filter(fs.existsSync);
      deps.forEach(function(dep) {
        var base1;
        if ((base1 = gulpProgeny.caches)[dep] == null) {
          base1[dep] = {};
        }
        return gulpProgeny.caches[dep][path] = 1;
      });
      return cb();
    });
  };
};

pushFileRecursive = function(fileSet, path) {
  var base1, cache, childPath, results;
  cache = ((base1 = gulpProgeny.caches)[path] != null ? base1[path] : base1[path] = {});
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

gulpProgeny = function(config) {
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
      if (!gulpProgeny.processedFileNames[path]) {
        gulpProgeny.processedFileNames[path] = 1;
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

gulpProgeny.caches = {};

gulpProgeny.processedFileNames = {};

module.exports = gulpProgeny;
