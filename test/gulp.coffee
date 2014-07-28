gutil = require('gulp-util')
path = require('path')
progeny = require('../dest/index')
fs = require('fs')

testPath = path.join(__dirname, 'fixtures/test.jade')
altPath = path.join(__dirname, 'fixtures/altExtensions.jade')

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

stream = progeny()
stream.on('data', (data)->
	# console.log(data)
)
stream.write(testFile)
stream.write(altFile)
stream.write(altFile)
