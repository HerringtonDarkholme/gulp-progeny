sysPath = require('path')
colors = require('colors/safe')

debugDep = (path, depList) ->
	formatted = depList.map((p) -> '    |--' + sysPath.relative('.', p)).join('\n')
	console.error(colors.green.bold('DEP') + ' ' + sysPath.relative('.', path))
	console.error(formatted || '    |  NO-DEP')

module.exports = debugDep
