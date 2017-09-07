"use strict";

const gulp = require('gulp');
const babel = require('gulp-babel');
const del = require('del');
const exec = require('child_process').exec;
const merge = require('merge-stream');
const output = 'build/';
const jsonEditor = require('gulp-json-editor');

gulp.task('prepublish', function () {
    del.sync([output]);

    const src = gulp.src(['lib/**'])
        .pipe(babel({
            presets: ['react-native']
        }))
        .pipe(gulp.dest(output));

    const readme = gulp.src(['README.md'])
        .pipe(gulp.dest(output));

    const packageJson = gulp.src(['package.json'])
        .pipe(jsonEditor({
            'main': 'index.js'
        }))
        .pipe(gulp.dest(output));

    return merge(src, readme, packageJson);
});

// Used for debugging changes to the prepublish pipeline
gulp.task('pack', ['prepublish'], function (cb) {
    exec('npm pack ' + output, function (err, stdout, stderr) {
        console.log(stdout);
        console.log(stderr);
        cb(err);
    });
});

gulp.task('publish', ['prepublish'], function (cb) {
    exec('npm publish ' + output, function (err, stdout, stderr) {
        console.log(stdout);
        console.log(stderr);
        cb(err);
    });
});
