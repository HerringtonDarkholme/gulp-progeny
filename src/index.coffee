gutil = require('gulp-util')
through = require('through2')
sysPath = require('path')
fs = require('fs')
progeny = require('./parse')

makeFile = (path, type, base, cwd) ->
	file = new gutil.File({
		base: base
		cwd: cwd
		path: path
		stat: fs.statSync(path)
	})
	if type is 'stream'
		file.contents = fs.createReadStream(path)
	else
		file.contents = fs.readFileSync(path)
	file


initParseConfig = (config) ->
	parser = progeny(config)
	(path) ->
		# clear old dependencies
		Object.keys(plugin.depCache).forEach (key) ->
			if path of plugin.depCache[key]
				delete plugin.depCache[key][path]
		parser(path, true)
			.filter(fs.existsSync)
			.forEach((dep) ->
				plugin.depCache[dep] ?= {}
				plugin.depCache[dep][path] = 1
			)

pushFileRecursive = (fileSet, path) ->
	cache = (plugin.depCache[path] ?= {})
	# refresh cache
	for childPath of cache
		if !fs.existsSync(childPath)
			delete cache[childPath]
		else
			fileSet[childPath] = 1
			pushFileRecursive(fileSet, childPath)


plugin = (config) ->
	getDeps = initParseConfig(config)
	return through.obj (file, enc, cb) ->
		if file.isNull()
			@push(file)
			return cb()

		path = file.path
		type = file.isStream() ? 'stream' : 'buffer'
		cwd = file.cwd
		base = file.base
		@push(file)
		getDeps(path)

		# do nothing when start up
		if !plugin.processedFileNames[path]
			plugin.processedFileNames[path] = 1
			return cb()
		fileSet = {}
		pushFileRecursive(fileSet, path)
		for childPath of fileSet
			@push(makeFile(childPath, type, base, cwd))
		cb()

# make this stores accessible, inspired by gulp-cached
plugin.depCache = {};
plugin.processedFileNames = {};

module.exports = plugin