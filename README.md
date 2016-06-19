gulp-progeny [![Build Status](https://travis-ci.org/HerringtonDarkholme/gulp-progeny.svg?branch=master)](https://travis-ci.org/HerringtonDarkholme/gulp-progeny)
===============
A dependency-resolving plugin for Gulp.
It grabs all files related to one edition to building system.

##Introduction
Gulp provides [incremental building](https://github.com/wearefractal/gulp-cached).
However it is agnostic about the dependencies among files.
Say, if `child.jade` depends on `parent.jade`, then whenever `parent` changes `child` should be recompiled as well.
Existing gulp plugins do not support this. Or one could fall back on `edit-wait-10s-view` loop.

`gulp-progeny` aims to solve this. If `parent.jade` is edited and passed to `gulp-progeny`, all files that recursively depends on that file will be collected by `progeny` and are passed to succesive building stream.

##What does gulp-progeny do
This plugin brings the agility of [brunch](https://github.com/brunch/brunch) to gulp world.
It provides generic dependency detection to various file types.
`progeny` parses files by grepping specific `import statements`, and builds dependency trees for building tasks.
So it just use Regular Expression to extract dependency information. This simple solution is fast and dirty, but also working.

##Usage
`gulp-progeny` out of box supports `jade`, `less`, `sass` and `stylus`.
To exploit the power of `gulp-progeny`, use `gulp-cached` in tandem.

```javascript
var cache = require('gulp-cached');
var progeny = require('gulp-progeny');
var stylus = require('gulp-stylus');

gulp.task('style', function(){
  return gulp.src('*.styl')
    .pipe(cache('style'))
    .pipe(progeny())
    .pipe(stylus())
});

gulp.task('watch', function(){
  gulp.watch('*.styl', ['style']);
});
```

`cached` will pass all files to `progeny` in the first run, which enables dependency tree building,
just pass changed files later for incremental building.

## Advanced configuration
As `gulp-progeny` includes `progeny` in its core, please see their [configuration docs](https://github.com/es128/progeny#configuration) for the options that can be used with this plugin.

### Limitation
`gulp-progeny`, by the virtue of its design, has following limitations.

1. Filenames must be static in source code. Otherwise regexp fails to work.

2. Sass/Scss filenames should not contain apostrophes. This limitation is due toSass's [multiple import feature](http://sass-lang.com/documentation/file.SASS_REFERENCE.html#import). Matching filenames with `'"` is far beyond the reach of regular expressions with only one match, which is the format used in this plug in.

Limitations above are almost ineluctable for this simple plugin. To keep API and extension simple and generic, some features are doomed to be dropped. This plugin does not fill the chasm between a single one Regexp and full-bloom parsers.
