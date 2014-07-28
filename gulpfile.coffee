gulp = require('gulp')
coffee = require('gulp-coffee')
gutil = require('gulp-util')
mocha = require('gulp-mocha')

gulp.task('coffee', ->
	gulp.src('./src/**/*.coffee')
		.pipe(coffee(bare: true))
		.on('error', gutil.log)
		.pipe(gulp.dest('./dest'))
)

gulp.task('watch', ->
	gulp.watch('src/**/*.coffee', ['coffee'])
)

gulp.task('test', ['coffee'], ->
	gulp.src('test/*.coffee')
		.pipe(mocha(
			compiler: 'coffee:coffee-script/register'
			reporter: 'nyan'
		))
)

gulp.task('default', ['coffee', 'watch'])
