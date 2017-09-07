"use strict";

const gulp = require('gulp');
const babel = require('gulp-babel');
const del = require('del');
const exec = require('child_process').exec;
const merge = require('merge-stream');
const output = 'build/';

gulp.task('prepublish', function () {
    del.sync([output]);

    const src = gulp.src(['lib/**'])
        .pipe(babel({
            presets: ['react-native']
        }))
        .pipe(gulp.dest(output));

    const extra = gulp.src(['README.md', 'package.json'])
        .pipe(gulp.dest(output));

    return merge(src, extra);
});

gulp.task('publish', ['prepublish'], function (cb) {
    exec('npm publish ' + output, function (err, stdout, stderr) {
        console.log(stdout);
        console.log(stderr);
        cb(err);
    });
});
