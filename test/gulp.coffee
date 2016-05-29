gutil = require('gulp-util')
path = require('path')
progeny = require('../dest/index')
fs = require('fs')
assert = require('assert')

testPath = path.join(__dirname, 'fixtures', 'test.jade')
altPath = path.join(__dirname, 'fixtures', 'altExtensions.jade')
partialPath = path.join(__dirname, 'fixtures', 'htmlPartial.html')

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
	stream = progeny(debug: false)
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

	it 'should deeply watch', (done) ->
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
					assert altCount is 3
					i++
				when 7
					assert testCount is 3
				else
					assert false
		stream = prepareTestStream(test)
		stream.on('end', -> done())
		stream.write(testFile)
		stream.write(altFile)
		stream.write(altFile)
		stream.write(partialFile)
		stream.write(partialFile)
		stream.end()

	it 'should handle stylus glob', (done) ->
		styl = path.join(__dirname, 'fixtures', 'test.styl')
		aPath = path.join(__dirname, 'fixtures', 'styl', 'a.styl')
		bPath = path.join(__dirname, 'fixtures', 'styl', 'b.styl')
		stream = progeny()
		i = a = b = t = 0
		stream.on('data', (data)->
			p = data.path
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
			done()
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

parentPath = path.join(__dirname, 'fixtures', 'parent.test')
childPath = path.join(__dirname, 'fixtures', 'child.test')
parentFile = new gutil.File({
	base: path.dirname(parentPath)
	cwd: __dirname
	path: parentPath
	contents: fs.readFileSync(parentPath)
})
fs.writeFileSync(childPath, 'import parent.test')
childFile = new gutil.File({
	base: path.dirname(childPath)
	cwd: __dirname
	path: childPath
	contents: fs.readFileSync(childPath)
})

describe 'gulp progeny should clean previous dep', ->
	it 'should track dep', (done) ->
		stream = progeny(regexp: /import (.*)/)
		parentCount = 0
		childCount = 0
		stream.on('data', (data)->
			p = data.path
			switch
				when /parent\.test$/.test(p)
					parentCount++
				when /child\.test$/.test(p)
					childCount++
			[expectedParentCount, expectedChildCount] = expectedCount.shift()
			if expectedChildCount == 3
				# hardcode a child path
				fs.writeFileSync(childPath, '')
			assert expectedParentCount == parentCount
			assert expectedChildCount == childCount
		).on('end', -> done())

		expectedCount = [
			[1, 0] #first
			[1, 1] #first
			[1, 2] #send child
			[2, 2] #send parent
			[2, 3] #send parent
			[2, 4] #change child
			[3, 4] #send parent again
			[-1, -1] # should not go here
		]
		# first time
		stream.write(parentFile)
		stream.write(childFile)

		# send child should not influence parent
		stream.write(childFile)
		# send parent again
		stream.write(parentFile)
		# change child
		stream.write(childFile)
		# send parent again should not update child
		stream.write(parentFile)
		stream.end()
