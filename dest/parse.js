var $, Is, Match, convertToGlobalRegExp, defaultSettings, fs, parameter, sysPath, wildcard, _, _ref,
  __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

sysPath = require('path');

defaultSettings = require('./setting');

fs = require('fs');

_ref = require('pat-mat'), Match = _ref.Match, Is = _ref.Is, parameter = _ref.parameter, wildcard = _ref.wildcard;

$ = parameter;

_ = wildcard;

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

module.exports = function(_arg) {
  var addExtension, alternateExtension, exclusion, extension, extensionsList, extractDepString, filterExclusion, normalizeExt, normalizePath, parseDeps, prefix, prefixify, regexp, rootPath, skip, stripComments, _ref1;
  _ref1 = _arg != null ? _arg : {}, skip = _ref1.skip, regexp = _ref1.regexp, exclusion = _ref1.exclusion, extension = _ref1.extension, rootPath = _ref1.rootPath, prefix = _ref1.prefix, extensionsList = _ref1.extensionsList;
  stripComments = function(source) {
    if (!skip) {
      return source;
    }
    skip = convertToGlobalRegExp(skip);
    return source.replace(skip, '');
  };
  extractDepString = function(source) {
    var match, _results;
    regexp = convertToGlobalRegExp(regexp);
    _results = [];
    while ((match = regexp.exec(source))) {
      _results.push(match[1]);
    }
    return _results;
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
  parseDeps = function(path, parsedList, recursive) {
    var deps, parentPath, source;
    if (path) {
      parentPath = sysPath.dirname(path);
    }
    source = fs.readFileSync(path, 'utf8');
    source = stripComments(source);
    deps = extractDepString(source).filter(filterExclusion).map(addExtension).map(normalizePath(parentPath));
    deps = normalizeExt(deps);
    deps = prefixify(deps);
    deps = alternateExtension(deps);
    if (!recursive) {
      return;
    }
    return deps.forEach(function(childPath) {
      if (!(__indexOf.call(parsedList, childPath) >= 0)) {
        parsedList.push(childPath);
        if (fs.existsSync(childPath)) {
          return parseDeps(childPath, parsedList);
        }
      }
    });
  };
  return function(path, recursive) {
    var depList, setting;
    if (recursive == null) {
      recursive = true;
    }
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
      extensionsList = setting.exclusion || [];
    }
    parseDeps(path, depList, recursive);
    return depList;
  };
};
