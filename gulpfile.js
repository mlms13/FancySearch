var gulp = require('gulp'),
    gutil = require('gulp-util'),

    // plugins and such
    prefix = require('gulp-autoprefixer'),
    rename = require('gulp-rename'),
    stylus = require('gulp-stylus');

gulp.task('stylus', function () {
  gulp.src('./demo/styl/index.styl')
    .pipe(stylus())
    .pipe(prefix())
    .pipe(rename('basic.css'))
    .pipe(gulp.dest('./bin/'))
});

gulp.task('build', ['stylus']);

gulp.task('watch', ['build'], function () {
  gulp.watch(['./demo/styl/**/*.styl'], ['stylus']);
});

gulp.task('default', ['watch']);
