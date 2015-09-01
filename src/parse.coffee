sysPath = require('path')
defaultSettings = require('./setting')
fs = require('fs')
{Match, Is, parameter, wildcard} = require('pat-mat')
$ = parameter
_ = wildcard
glob = require('glob')
debugDep = require('./util')


convertToGlobalRegExp = Match(
	Is {global: true, multiline: true}, -> @m
	Is {source: $}, (s)-> new RegExp(s, 'mg')
)


module.exports = ({skip, regexp, exclusion, extension, rootPath, prefix, extensionsList, directoryEntry, debug} = {}) ->

	stripComments = (source) ->
		if !skip
			return source
		skip = convertToGlobalRegExp(skip)
		source.replace(skip, '')

	extractDepString = (source, path) ->
		regexp = convertToGlobalRegExp(regexp)
		ret = []
		splitReg = /['"]\s*,\s*['"]/
		while (match = regexp.exec(source))
			str = match[1]
			if splitReg.test(str)
				# handle sass multiple import
				ret = ret.concat(str.split(splitReg))
			else if /\*/.test(str)
				# handle stylus file glob
				ret = ret.concat(glob.sync(str, {
					root: rootPath,
					cwd: sysPath.dirname(path)
				}))
			else
				ret.push(str)
		ret

	filterExclusion = (path) ->
		isExcluded = Match(
			Is RegExp, -> @m.test(path)
			Is String, -> @m is path
			Is Array, -> @m.some((e) -> isExcluded(e))
			Is _, -> false
		)
		!isExcluded(exclusion)

	addExtension = (path) ->
		if extension and '' is sysPath.extname(path)
			path + '.' + extension
		else
			path

	addDirectory = (path) ->
		if (
			directoryEntry and
			'' is sysPath.extname(path) and
			fs.existsSync(path) and
			fs.lstatSync(path).isDirectory()
		)
			path + '/' + directoryEntry
		else
			path


	normalizePath = (parentPath) -> (path) ->
		if path[0] is '/' or not parentPath
			sysPath.join(rootPath, path[1..])
		else
			sysPath.join(parentPath, path)

	normalizeExt = (depList) ->
		if not extension
			return depList
		depList.forEach (path) ->
			if ".#{extension}" isnt sysPath.extname(path)
				depList.push(path + '.' + extension)
		depList

	prefixify = (depList) ->
		if not prefix
			return depList
		prefixed = []
		depList.forEach (path) ->
			dir = sysPath.dirname(path)
			file = sysPath.basename(path)
			if file.indexOf(prefix) isnt 0
				prefixed.push(sysPath.join(dir, prefix + file))
		depList.concat(prefixed)

	alternateExtension = (depList) ->
		if not extensionsList?.length
			return depList
		altExts = []
		depList.forEach (path) ->
			dir = sysPath.dirname path
			extensionsList.forEach (ext) ->
				if ".#{ext}" isnt sysPath.extname path
					base = sysPath.basename(path, '.' + extension)
					altExts.push(sysPath.join(dir, base + '.' + ext))
		depList.concat(altExts)

	parseDeps = (path, parsedList, shallowDep) ->
		parentPath = sysPath.dirname(path) if path
		source = fs.readFileSync(path, 'utf8')
		source = stripComments(source)
		deps = extractDepString(source, path)
			.filter(filterExclusion)
			.map(normalizePath(parentPath))
			.map(addDirectory)
			.map(addExtension)
		deps = normalizeExt(deps)
		deps = prefixify(deps)
		deps = alternateExtension(deps)

		deps.forEach (childPath) ->
			if not (childPath in parsedList)
				parsedList.push(childPath)
				if shallowDep
					return
				if fs.existsSync(childPath)
					parseDeps(childPath, parsedList)

	(path, shallowDep) ->
		depList = []
		extension ?= sysPath.extname(path)[1...]
		setting = defaultSettings(extension)
		regexp ?= setting.regexp
		prefix ?= setting.prefix
		exclusion ?= setting.exclusion
		skip ?= setting.skip
		extensionsList ?= setting.extensionsList or []
		directoryEntry ?= setting.directoryEntry
		parseDeps(path, depList, shallowDep)
		if debug
			debugDep(path, depList)
		depList
