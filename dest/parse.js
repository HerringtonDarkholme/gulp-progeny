var $, Is, Match, _, convertToGlobalRegExp, defaultSettings, fs, glob, parameter, ref, sysPath, wildcard,
  indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

sysPath = require('path');

defaultSettings = require('./setting');

fs = require('fs');

ref = require('pat-mat'), Match = ref.Match, Is = ref.Is, parameter = ref.parameter, wildcard = ref.wildcard;

$ = parameter;

_ = wildcard;

glob = require('glob');

convertToGlobalRegExp = Match(Is({
  global: true,
  multiline: true
}, function() {
  return this.m;
}), Is({
  source: $
}, function(s) {
  return new RegExp(s, 'mg');
}));

module.exports = function(arg) {
  var addDirectory, addExtension, alternateExtension, directoryEntry, exclusion, extension, extensionsList, extractDepString, filterExclusion, normalizeExt, normalizePath, parseDeps, prefix, prefixify, ref1, regexp, rootPath, skip, stripComments;
  ref1 = arg != null ? arg : {}, skip = ref1.skip, regexp = ref1.regexp, exclusion = ref1.exclusion, extension = ref1.extension, rootPath = ref1.rootPath, prefix = ref1.prefix, extensionsList = ref1.extensionsList, directoryEntry = ref1.directoryEntry;
  stripComments = function(source) {
    if (!skip) {
      return source;
    }
    skip = convertToGlobalRegExp(skip);
    return source.replace(skip, '');
  };
  extractDepString = function(source, path) {
    var match, ret, splitReg, str;
    regexp = convertToGlobalRegExp(regexp);
    ret = [];
    splitReg = /['"]\s*,\s*['"]/;
    while ((match = regexp.exec(source))) {
      str = match[1];
      if (splitReg.test(str)) {
        ret = ret.concat(str.split(splitReg));
      } else if (/\*/.test(str)) {
        ret = ret.concat(glob.sync(str, {
          root: rootPath,
          cwd: sysPath.dirname(path)
        }));
      } else {
        ret.push(str);
      }
    }
    return ret;
  };
  filterExclusion = function(path) {
    var isExcluded;
    isExcluded = Match(Is(RegExp, function() {
      return this.m.test(path);
    }), Is(String, function() {
      return this.m === path;
    }), Is(Array, function() {
      return this.m.some(function(e) {
        return isExcluded(e);
      });
    }), Is(_, function() {
      return false;
    }));
    return !isExcluded(exclusion);
  };
  addExtension = function(path) {
    if (extension && '' === sysPath.extname(path)) {
      return path + '.' + extension;
    } else {
      return path;
    }
  };
  addDirectory = function(path) {
    if (directoryEntry && '' === sysPath.extname(path) && fs.lstatSync(path).isDirectory()) {
      return path + '/' + directoryEntry;
    } else {
      return path;
    }
  };
  normalizePath = function(parentPath) {
    return function(path) {
      if (path[0] === '/' || !parentPath) {
        return sysPath.join(rootPath, path.slice(1));
      } else {
        return sysPath.join(parentPath, path);
      }
    };
  };
  normalizeExt = function(depList) {
    if (!extension) {
      return depList;
    }
    depList.forEach(function(path) {
      if (("." + extension) !== sysPath.extname(path)) {
        return depList.push(path + '.' + extension);
      }
    });
    return depList;
  };
  prefixify = function(depList) {
    var prefixed;
    if (!prefix) {
      return depList;
    }
    prefixed = [];
    depList.forEach(function(path) {
      var dir, file;
      dir = sysPath.dirname(path);
      file = sysPath.basename(path);
      if (file.indexOf(prefix) !== 0) {
        return prefixed.push(sysPath.join(dir, prefix + file));
      }
    });
    return depList.concat(prefixed);
  };
  alternateExtension = function(depList) {
    var altExts;
    if (!(extensionsList != null ? extensionsList.length : void 0)) {
      return depList;
    }
    altExts = [];
    depList.forEach(function(path) {
      var dir;
      dir = sysPath.dirname(path);
      return extensionsList.forEach(function(ext) {
        var base;
        if (("." + ext) !== sysPath.extname(path)) {
          base = sysPath.basename(path, '.' + extension);
          return altExts.push(sysPath.join(dir, base + '.' + ext));
        }
      });
    });
    return depList.concat(altExts);
  };
  parseDeps = function(path, parsedList) {
    var deps, parentPath, source;
    if (path) {
      parentPath = sysPath.dirname(path);
    }
    source = fs.readFileSync(path, 'utf8');
    source = stripComments(source);
    deps = extractDepString(source, path).filter(filterExclusion).map(normalizePath(parentPath)).map(addDirectory).map(addExtension);
    deps = normalizeExt(deps);
    deps = prefixify(deps);
    deps = alternateExtension(deps);
    return deps.forEach(function(childPath) {
      if (!(indexOf.call(parsedList, childPath) >= 0)) {
        parsedList.push(childPath);
        if (fs.existsSync(childPath)) {
          return parseDeps(childPath, parsedList);
        }
      }
    });
  };
  return function(path) {
    var depList, setting;
    depList = [];
    if (extension == null) {
      extension = sysPath.extname(path).slice(1);
    }
    setting = defaultSettings(extension);
    if (regexp == null) {
      regexp = setting.regexp;
    }
    if (prefix == null) {
      prefix = setting.prefix;
    }
    if (exclusion == null) {
      exclusion = setting.exclusion;
    }
    if (skip == null) {
      skip = setting.skip;
    }
    if (extensionsList == null) {
      extensionsList = setting.extensionsList || [];
    }
    if (directoryEntry == null) {
      directoryEntry = setting.directoryEntry;
    }
    parseDeps(path, depList);
    return depList;
  };
};
