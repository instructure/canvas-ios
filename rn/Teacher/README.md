#Teacher App

### Getting started
Ensure that you have followed all of the steps to get React Native dependencies on your machine.
https://facebook.github.io/react-native/docs/getting-started.html

Run `npm install -g yarn`
From the project root run `yarn install`

Run `react-native run-ios` and it should start up the app

### Linting
We use the eslint config from the project http://standardjs.com/.
If needed we can customize these rules in `.eslintrc`

To lint from the command line run `yarn run lint`
You can also run `yarn run lint:fix` to tell eslint to try and fix as many errors as it knows how
To have the linter watch for changes from the command line run `yarn run lint:watch`

In VS Code you can install the extension ESLint to get linting using our .eslintrc file inside of the editor
