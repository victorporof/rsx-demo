// Any copyright is dedicated to the Public Domain.
// http://creativecommons.org/publicdomain/zero/1.0/

import del from 'del';
import gulp from 'gulp';
import exec from 'gulp-exec';
import flatten from 'gulp-flatten';
import rename from 'gulp-rename';
import serve from 'serve';
import yargs from 'yargs';

const TARGET = yargs.argv.target || 'asmjs-unknown-emscripten';
const RELEASE = yargs.argv.release ? '--release' : '';
const DIST_DIR = './dist/target-web';

console.log(`TARGET = ${TARGET}`);
console.log(`RELEASE = ${RELEASE}`);

const CARGO_EXEC_OPTIONS = {
  pipeStdout: true,
};

gulp.task('clean', () =>
  del(['./dist']));

gulp.task('build-web:copy-html', () =>
  gulp.src('./fixtures/web/**/*.html')
    .pipe(flatten())
    .pipe(gulp.dest(DIST_DIR)));

gulp.task('build-web:copy-js', () =>
  gulp.src('./rsx-renderers/packages/web-renderer/dist/bundle/**/*.{js,map}')
    .pipe(flatten())
    .pipe(gulp.dest(DIST_DIR)));

gulp.task('build-web:copy-rust', () =>
  gulp.src(`./target/${TARGET}/${RELEASE ? 'release' : 'debug'}/*.{js,map}`)
    .pipe(rename({ basename: 'main.rs' }))
    .pipe(gulp.dest(DIST_DIR)));

gulp.task('build-web:cargo', () =>
  gulp.src('./Cargo.toml')
    .pipe(exec(`cargo build --manifest-path <%= file.path %> --target=${TARGET} ${RELEASE}`, CARGO_EXEC_OPTIONS))
    .pipe(exec.reporter()));

gulp.task('build', gulp.series(
  'clean',
  'build-web:cargo',
  'build-web:copy-html',
  'build-web:copy-js',
  'build-web:copy-rust',
));

gulp.task('open', () =>
  serve(DIST_DIR, { open: yargs.argv.open }));

gulp.task('start', gulp.series(
  'build',
  'open',
));
