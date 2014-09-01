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
	# it 'add count', ->
	# 	test = ->
	# 		assert testCount is 1
	# 	stream = prepareTestStream(test)
	# 	stream.write(testFile)

	# it 'should only add count to new file', ->
	# 	i = 0
	# 	test = ->
	# 		switch i
	# 			when 0
	# 				assert testCount is 1
	# 				i++
	# 			when 1
	# 				assert altCount is 1
	# 			else
	# 				assert false
	# 	stream = prepareTestStream(test)
	# 	stream.write(testFile)
	# 	stream.write(altFile)

	# it 'should add dependent file count', ->
	# 	i = 0
	# 	test = ->
	# 		switch i
	# 			when 0
	# 				assert testCount is 1
	# 				i++
	# 			when 1
	# 				assert altCount is 1
	# 				i++
	# 			when 2
	# 				assert altCount is 2
	# 				i++
	# 			when 3
	# 				assert testCount is 2
	# 			else
	# 				assert false
	# 	stream = prepareTestStream(test)
	# 	stream.write(testFile)
	# 	stream.write(altFile)
	# 	stream.write(altFile)

	it 'should deeply watch', ->
		i = 0
		test = ->
			switch i
				when 0
					assert testCount is 1
					i++
				when 1
					assert altCount is 1
					i++
				when 2
					assert altCount is 2
					i++
				when 3
					assert testCount is 2
					i++
				when 4
					assert partialCount is 1
					i++
				when 5
					assert partialCount is 2
					i++
				when 6
					assert testCount is 3
					i++
				when 7
					assert altCount is 3
				else
					assert false
		stream = prepareTestStream(test)
		stream.write(testFile)
		stream.write(altFile)
		stream.write(altFile)
		stream.write(partialFile)
		stream.write(partialFile)

	it 'should handle stylus glob', ->
		styl = path.join(__dirname, 'fixtures/test.styl')
		aPath = path.join(__dirname, 'fixtures/styl/a.styl')
		bPath = path.join(__dirname, 'fixtures/styl/b.styl')
		stream = progeny()
		i = a = b = t = 0
		stream.on('data', (data)->
			p = data.path
			console.log(p)
			i++
			switch
				when /a\.styl$/.test(p)
					a++
				when /b\.styl$/.test(p)
					b++
				when /test\.styl/.test(p)
					t++
		).on('end', ->
			assert i == 7
			assert a is 2
			assert b is 2
			assert t = 3
		)
		stylFile = new gutil.File({
			base: path.dirname(styl)
			cwd: __dirname
			path: styl
			contents: fs.readFileSync(styl)
		})
		aFile = new gutil.File({
			base: path.dirname(styl)
			cwd: __dirname
			path: aPath
			contents: fs.readFileSync(aPath)
		})
		bFile = new gutil.File({
			base: path.dirname(styl)
			cwd: __dirname
			path: bPath
			contents: fs.readFileSync(bPath)
		})
		stream.write(stylFile)
		stream.write(aFile)
		stream.write(aFile)
		stream.write(bFile)
		stream.write(bFile)
		stream.end()
