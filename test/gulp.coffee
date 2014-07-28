gutil = require('gulp-util')
path = require('path')
progeny = require('../dest/index')
fs = require('fs')
assert = require('assert')

testPath = path.join(__dirname, 'fixtures/test.jade')
altPath = path.join(__dirname, 'fixtures/altExtensions.jade')
partialPath = path.join(__dirname, 'fixtures/htmlPartial.html')

testFile = new gutil.File({
	base: path.dirname(testPath)
	cwd: __dirname
	path: testPath
	contents: fs.readFileSync(testPath)
})

altFile = new gutil.File({
	base: path.dirname(altPath)
	cwd: __dirname
	path: altPath
	contents: fs.readFileSync(altPath)
})

partialFile = new gutil.File({
	base: path.dirname(partialPath)
	cwd: __dirname
	path: partialPath
	contents: fs.createReadStream(partialPath)
})

testCount = altCount = partialCount = 0

prepareTestStream = (testFunc) ->
	stream = progeny()
	testCount = altCount = partialCount = 0
	stream.on('data', (data)->
		p = data.path
		console.log p
		switch
			when /test\.jade$/.test(p)
				testCount++
			when /altExtensions\.jade$/.test(p)
				altCount++
			when /htmlPartial\.html$/.test(p)
				partialCount++
		testFunc()
	)
	stream

describe 'gulp-progeny should', ->
	# it 'add count', (done)->
	# 	test = ->
	# 		assert testCount is 1
	# 		done()
	# 	stream = prepareTestStream(test)
	# 	stream.write(testFile)

	# it 'should only add count to new file', (done) ->
	# 	i = 0
	# 	test = ->
	# 		if i is 0
	# 			assert testCount is 1
	# 			i++
	# 		else if i is 1
	# 			assert altCount is 1
	# 			done()
	# 	stream = prepareTestStream(test, done)
	# 	stream.write(testFile)
	# 	stream.write(altFile)

	it 'should add dependent file count', (done) ->
		i = 0
		test = ->
			switch i
				when 0, 1
					i++
				when 2
					assert altCount is 2
					i++
				when 3
					assert testCount is 2
					done()
		stream = prepareTestStream(test)
		stream.write(testFile)
		stream.write(altFile)
		stream.write(altFile)

	# it 'should deeply watch', (done) ->
	# 	test = -> testCount is 3 and altCount is 3 and partialCount is 3
	# 	stream = prepareTestStream(test, done)
	# 	stream.write(testFile)
	# 	stream.write(altFile)
	# 	stream.write(altFile)
	# 	stream.write(partialFile)
	# 	stream.write(partialFile)
