sysPath = require('path')
defaultSettings = require('./setting')
fs = require('fs')
{Match, Is, parameter, wildcard} = require('pat-mat')
$ = parameter
_ = wildcard


convertToGlobalRegExp = Match(
	Is {global: true, multiline: true}, -> @m
	Is {source: $}, (s)-> new RegExp(s, 'mg')
)


module.exports = ({skip, regexp, exclusion, extension, rootPath, prefix, extensionsList} = {}) ->

	stripComments = (source) ->
		if !skip
			return source
		skip = convertToGlobalRegExp(skip)
		source.replace(skip, '')

	extractDepString = (source) ->
		regexp = convertToGlobalRegExp(regexp)
		match[1] while (match = regexp.exec(source))

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

	parseDeps = (path, parsedList, recursive) ->
		parentPath = sysPath.dirname(path) if path
		source = fs.readFileSync(path, 'utf8')
		source = stripComments(source)
		deps = extractDepString(source)
			.filter(filterExclusion)
			.map(addExtension)
			.map(normalizePath(parentPath))
		deps = normalizeExt(deps)
		deps = prefixify(deps)
		deps = alternateExtension(deps)

		if !recursive
			return
		deps.forEach (childPath) ->
			if not (childPath in parsedList)
				parsedList.push(childPath)
				if (fs.existsSync(childPath))
					parseDeps(childPath, parsedList)

	(path, recursive=true) ->
		depList = []
		extension ?= sysPath.extname(path)[1...]
		setting = defaultSettings(extension)
		regexp ?= setting.regexp
		prefix ?= setting.prefix
		exclusion ?= setting.exclusion
		skip ?= setting.skip
		extensionsList ?= setting.exclusion or []
		parseDeps(path, depList, recursive)
		depList
