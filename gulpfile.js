var gulp = require('gulp'),
    gutil = require('gulp-util'),

    // plugins and such
    fs = require('fs'),
    path = require('path'),
    prefix = require('gulp-autoprefixer'),
    rename = require('gulp-rename'),
    stylus = require('gulp-stylus');

var demoFolderPath = './demo';

function getFolders(dir) {
  return fs.readdirSync(dir)
    .filter(function (file) {
      return fs.statSync(path.join(dir, file)).isDirectory();
    });
}

gulp.task('stylus', function () {
  var task = gulp.src('./demo/index.styl')
    .pipe(stylus())
    .pipe(prefix())
    .pipe(rename('basic.css'));

  return getFolders(demoFolderPath).reduce(function (task, folder) {
    task.pipe(gulp.dest(path.join(demoFolderPath, folder, '/www/')));
    return task;
  }, task);
});

gulp.task('html', function () {
  return getFolders(demoFolderPath).reduce(function (task, folder) {
    task.pipe(gulp.dest(path.join(demoFolderPath, folder, '/www/')));
  }, gulp.src('./demo/index.html'));
})

gulp.task('build', ['stylus', 'html']);

gulp.task('watch', ['build'], function () {
  gulp.watch(['./demo/*.html'], ['html']);
  gulp.watch(['./demo/*.styl'], ['stylus']);
});

gulp.task('default', ['watch']);
