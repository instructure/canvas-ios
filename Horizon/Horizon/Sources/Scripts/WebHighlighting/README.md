The purpose of this project is to provide javascript functionality for highlighting text in a WKWebView.

The WebHighlighting/src/main.ts is the interface

---

## Getting Started

- install typescript: `npm i webpack webpack-cli typescript ts-loader --save-dev`
- compile: `npx tsc; npx webpack; rm -rf dist`

If you don't want it to reduce the code, specify `development` for the mode:

- npx tsc; npx webpack --mode development; rm -rf dist

This will build the `WebHighlighting.js` to the Resources directory of the iOS project

## Debugging

It may be easiest to spin up a server to test the javascript. I did this by running `npx http-server` in the `canvas-ios/Horizon/Horizon/Resources` so that it's running the generated JavaScript. I also copied over the `WebHighlighting/src/index.html` file to the `Resources` directory. This will allow you to test the JavaScript in a browser. The `index.html` is just a test page for trying out the highlighting, it isn't used in the production app.

The process isn't very polished, but its an OK starting point.
