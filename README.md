gulp-progeny [![Build Status](https://travis-ci.org/HerringtonDarkholme/gulp-progeny.svg?branch=master)](https://travis-ci.org/HerringtonDarkholme/gulp-progeny)
===============
A dependency-resolving plugin for gulp.
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
`gulp-progeny` out of box supports `jade`, `jedi`,`less`, `sass` and `stylus`.
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

##advanced configuration
Generally same as brunch's [progeny](https://github.com/es128/progeny).
Just pass configuration to progeny constructor.

```javascript
var progenyConfig = {
    // The file extension for the source code you want parsed
    // Will be derived from the source file path if not specified
    extension: 'styl',

    // Array of multiple file extensions to try when looking for dependencies
    extensionsList: ['scss', 'sass'],

    // Regexp to run on each line of source code to match dependency references
    // Make sure you wrap the file name part in (parentheses)
    regexp: /^\s*@import\s+['"]?([^'"]+)['"]?/,

    // File prefix to try (in addition to the raw value matched in the regexp)
    prefix: '_',

    // Matched stuff to exclude: string, regex, or array of either/both
    exclusion: /^compass/,

    // which file to find when import directory as a whole
    // don't include extension here
    // e.g. @import 'blueprint' is expanded to @import 'blueprint/index.styl'
    directoryEntry: 'index',

    // In case a match starts with a slash, the absolute path to apply
    rootPath: path.join('path', 'to', 'project'),

    // all dependencies will be printed out in debug mode
    debug: true
};
var progeny = require('gulp-progeny')

gulp.src('*.styl').pipe(progeny(progenyConfig))
```

### limitation
Gulp-progeny, by the virtue of its design, has following limitations.

1. Filenames must be static in source code. Otherwise regexp fails to work.

2. Sass/Scss filenames should not contain apostrophes. This limitation is due toSass's [multiple import feature](http://sass-lang.com/documentation/file.SASS_REFERENCE.html#import). Matching filenames with `'"` is far beyond the reach of regular expressions with only one match, which is the format used in this plug in.

Limitations above are almost ineluctable for this simple plugin. To keep API and extension simple and generic, some features are doomed to be dropped. This plugin does not fill the chasm between a single one Regexp and full-bloom parsers.

### changelog
0.0.1 initial version

0.0.2 fix `base` path in `gutil.File` to preserve directory structure

0.0.3 fix stylus regexp

0.0.4 add empty setting object for unsupported file type

0.0.5 fix extensions list

0.0.6 add `multiple import` for sass and `file glob` for stylus

0.0.7 drop support for apostroph

0.0.8 add support for index styles

0.1.1 add dependencies removal

0.2.0 add file.stats for other plugins
