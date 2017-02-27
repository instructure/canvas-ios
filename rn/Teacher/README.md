#Teacher App

### Getting started

- Install node. You probably should use 6.x or newer.
- Install yarn: https://yarnpkg.com/en/docs/install#mac-tab
- Follow the installation steps in the react native getting started guide:

https://facebook.github.io/react-native/docs/getting-started.html

- You may need to run the following after installing Xcode:

```
xcode-select --install
sudo xcode-select -s /Applications/Xcode.app
```

- Install node dependencies: `yarn install`
- Install carthage: `brew install carthage`
- Run a carthage checkout at the top level of the repo:
  `(cd ../.. ; carthage checkout --no-use-binaries)`
- Launch the app: `react-native run-ios`
  (note: if you already have a simulator running, kill it before running that
   command)

### BuddyBuild
In the root of the git repo is `buddybuild_postclone.sh` which will ensure that only the apps
with relevant changes will build. But because we can only cancel builds right now, the builds
in buddy build will show as failed. You should look to make sure that the Teacher App build
succeeded for all commits related to this app.

### Linting
We use the eslint config from the project http://standardjs.com/.
If needed we can customize these rules in `.eslintrc`

To lint from the command line run `yarn run lint`
You can also run `yarn run lint:fix` to tell eslint to try and fix as many errors as it knows how
To have the linter watch for changes from the command line run `yarn run lint:watch`

In VS Code you can install the extension ESLint to get linting using our .eslintrc file inside of the editor

#### Flow

Flow is installed inside of the project so if you would like to run flow you can run
`yarn run flow`. Be sure that you performed another `yarn install` to make sure you have flow installed.

If you would like to have flow working inside of VS Code install the `vscode-flow-ide` extension.
Then hit `CMD ,` and search for these two options and set them both to false:
`typescript.validate.enable`
`javascript.validate.enable`

### Testing

We use [jest](https://facebook.github.io/jest/) for testing.

To run the tests, run `yarn run test` from the command line. To have jest watch
for changes and intelligently run tests automatically run `yarn run jest -- --watch`.
