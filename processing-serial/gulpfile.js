var gulp = require('gulp');
var sass = require('gulp-sass');
var livereload = require('gulp-livereload');
var webpack = require('gulp-webpack');

// ------------------------------------------------------------------------
gulp.task('sass', function () {
  return gulp.src('./src/sass/main.scss')
    .pipe(sass().on('error', sass.logError))
    .pipe(gulp.dest('./app/css/'))
    .pipe(livereload());
});
 
// ------------------------------------------------------------------------
gulp.task('js', function() {
  return gulp.src('src/js/main.js')
    .pipe(webpack({
      output: {
        filename: 'main.js'
      }
    }))
    .pipe(gulp.dest('./app/js'))
    .pipe(livereload());
});

// ------------------------------------------------------------------------
gulp.task('copy', function () {
  gulp.src('node_modules/p5/lib/p5.min.js').pipe(gulp.dest('./app/js'));
  gulp.src('node_modules/p5/lib/addons/*.js').pipe(gulp.dest('./app/js'));
  gulp.src('node_modules/tone/build/tone.min.js').pipe(gulp.dest('./app/js'));
});



// ------------------------------------------------------------------------
gulp.task('watch', function () {
  livereload.listen();
  gulp.watch('./src/js/*', ['js']);
  gulp.watch('./app/*.html', ['js']);
  gulp.watch('./src/sass/*.scss', ['sass']);
});

gulp.task('default', ['sass', 'js', 'copy']);
