var colors, debugDep, sysPath;

sysPath = require('path');

colors = require('colors/safe');

debugDep = function(path, depList) {
  var formatted;
  formatted = depList.map(function(p) {
    return '    |--' + sysPath.relative('.', p);
  }).join('\n');
  console.error(colors.green.bold('DEP') + ' ' + sysPath.relative('.', path));
  return console.error(formatted || '    |  NO-DEP');
};

module.exports = debugDep;
