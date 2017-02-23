#Teacher App

### Getting started
Ensure that you have followed all of the steps to get React Native dependencies on your machine.
https://facebook.github.io/react-native/docs/getting-started.html

Run `brew update` then `brew install yarn`
From the project root run `yarn install`

Run `react-native run-ios` and it should start up the app

### Linting
We use the eslint config from the project http://standardjs.com/.
If needed we can customize these rules in `.eslintrc`

To lint from the command line run `yarn run lint`
You can also run `yarn run lint:fix` to tell eslint to try and fix as many errors as it knows how
To have the linter watch for changes from the command line run `yarn run lint:watch`

In VS Code you can install the extension ESLint to get linting using our .eslintrc file inside of the editor

####Flow

Flow is installed inside of the project so if you would like to run flow you can run
`yarn run flow`. Be sure that you performed another `yarn install` to make sure you have flow installed.

If you would like to have flow working inside of VS Code install the `vscode-flow-ide` extension.
Then hit `CMD ,` and search for these two options and set them both to false:
`typescript.validate.enable`
`javascript.validate.enable`
