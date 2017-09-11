"use strict";

const gulp = require('gulp');
const babel = require('gulp-babel');
const del = require('del');
const exec = require('child_process').exec;
const merge = require('merge-stream');
const output = 'build/';

gulp.task('prepublish', function () {
    del.sync([output]);

    const src = gulp.src(['lib/**', '!lib/flow/*'])
        .pipe(babel({
            presets: ['react-native']
        }))
        .pipe(gulp.dest(output + 'lib/'));

    const files = gulp.src(['README.md', 'package.json'])
        .pipe(gulp.dest(output));

    const flow = gulp.src(['lib/flow/*'])
        .pipe(gulp.dest(output + 'lib/flow/'));

    return merge(src, files, flow);
});

function runCommand(command, cb) {
    console.log("$ " + command);
    exec(command, function (err, stdout, stderr) {
        console.log(stdout);
        console.log(stderr);
        cb(err);
    });
}

// Used for debugging changes to the prepublish pipeline
gulp.task('pack', ['prepublish'], function (cb) {
    runCommand('npm pack ' + output, cb);
});

// npm publish runs scripts: { "prepublishOnly": "gulp prepublish" }
gulp.task('publish', function (cb) {
    runCommand('npm publish ' + output, cb);
});
