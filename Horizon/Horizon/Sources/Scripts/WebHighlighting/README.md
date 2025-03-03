The purpose of this project is to provide javascript functionality for highlighting text in a WKWebView.

The index.ts is the interface

To compile the .ts files to a single .js file, run

---

## Getting Started

- install typescript: `npm i webpack webpack-cli typescript ts-loader --save-dev`
- compile: `npx tsc; npx webpack; rm -rf dist`

If you don't want it to reduce the code, specify `development` for the mode:

- npx tsc; npx webpack --mode development; rm -rf dist

This will build the `WebHighlighting.js` to the Resources directory of the iOS project

## Debugging

## Directory Structure

/src - contains the typescript files
/dist - after compiling the typescript, outputs the javascript
