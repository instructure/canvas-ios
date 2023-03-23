# Canvas iOS Apps

- [Student](https://itunes.apple.com/us/app/canvas-student/id480883488?mt=8)
- [Teacher](https://itunes.apple.com/us/app/canvas-teacher/id1257834464?mt=8)
- [Parent](https://itunes.apple.com/us/app/canvas-parent/id1097996698?mt=8)


## Getting Started on Development

1. Clone the repository

```sh
git clone git@github.com:instructure/canvas-ios.git
```

2. Install Homebrew

```sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

3. CD to the project root folder to install project dependencies defined in the `Brewfile`

```sh
make provision
```

4. CD to the project root folder to generate project files and build yarn dependencies
```sh
make sync
```

### Troubleshooting

#### make sync error
If you run into the error *xcrun: error: SDK "iphoneos" cannot be located`.*

Set Xcode Command Line Tools: 
```sh
 sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
```

#### NPM error
If you have an NPM related error try installing watchman directly. 
```sh
brew install watchman
```

and then run 
```sh
sudo launchctl limit maxfiles 16384 16384 && ulimit -n 16384
```

### Secrets

Any static keys, tokens, passwords, or other secrets that need to be available in the app bundle should be added as a case to `Secret.swift`.

The secrets necessary for a particular build are generated as data assets using a script.

```sh
yarn build-secrets "studentPSPDFKitLicense=token1" "teacherPSPDFKitLicense=token2"
```

You will need to purchase PSPDFKitLicenses to distribute custom apps. Instructure's licenses are only used for official builds and are not included in the repository.


### Debugging Redux

To get redux logs you can add [redux-logger](https://github.com/LogRocket/redux-logger) as a middleware to the redux store.

We don't want to keep the logger in because it slows down the runtime quite a lot.

In src/redux/store.js
```js
import logger from 'redux-logger'

let middleware = [promiseMiddleware, errorHandler, createPersisteMiddleware(500), logger]
```

The redux logs will now show up in the React Native Debugger.

## Contributing Guiding Principles

### Simple

Writing an app is complex. Decisions made from the beginning have a big impact on the end result.

We strive to maintain a simple architecture that is easy to understand and pick up. Someone familiar with the platform should be productive within a single day.

Code should be self-documenting and easy to follow.

```
Ugly code is easy to recognize and its cost is easy to estimate. Neither is true for a wrong abstraction.
- Dan Abramov
```

### Easy to Debug

Surprise! Apps have bugs. Industry average is 15-50 defects per 1000 lines of code.

We build our apps in a way that makes finding and fixing issues is as easy as possible.

### Testable

Writing code in a testable way is paramount for long term success. These apps are built in a way that makes our unit testing surface as large as possible.

### Conventions

We make and keep strong [conventions](./CONVENTIONS.md) in order to reduce mental overhead.

### No Tricky Stuff

We do things the Apple prescribed way because it offers the best long term predictability with minimal maintenance.

### Fat Model, Thin Controller

Models & Presenters handle as much of the business logic as possible. This allows a wide unit testing surface. Views & View Controllers should be as small as possible.

### Predictable

By scrutinizing each dependency we bring in, the code we write is our responsibility. Unit tests are a key portion of the code we write, so as time passes, the code that worked 2 years ago still works today.

### Automation

We don't do any manual QA of our products. We write code that tests our apps for us.

### Prune Legacy Code

😬 One day React Native, Cocoapods, and other old frameworks will be fully replaced by the swift architecture in Core. Eventually. Hopefully. 🤞


## Using the Canvas Apps

### How to connect to a local canvas instance or a Portal instance
https://instructure.atlassian.net/wiki/spaces/MOBILE/pages/563937366/Manual+Oauth+Login+Bypassing+mobile+verify

If you are connecting to a portal instance you must be connected to the VPN. This requires Full VPN tunnel and not just the typical Employee VPN connection. After you hit connect in the Cisco VPN client to connect to vpn.instructure.com there will be a drop down where you can select Full Tunnel

### Generating icons from [instructure.design](https://instructure.design/#iconography)

Most, if not all of the icons used in the Canvas apps can be found in instructure-icons, but are defined as React components, SVG, & Sketch files. Since iOS does not handle SVG files in UIImageViews natively, these are converted to PDF.

```sh
yarn build-icons
```

### Generating code coverage report

You can generate code coverage reports with `yarn coverage --scheme <SCHEME>`

#### Student
```bash
yarn coverage --scheme Student
```

#### Core
```bash
yarn coverage --scheme Core
```

To run tests first use `yarn test`
```bash
yarn test --scheme Core
```

| Option | Description |
| ------ | ----------- |
| scheme  | The scheme to run against  |
| os  | Specify simulator os. Only available when running tests  |


## Open Source Licenses Used

We have a script that should ensure the correct license header comments are in place:

```sh
yarn update-headers
```

#### Our applications are licensed under the AGPLv3 License.

```
This file is part of Canvas.
Copyright (C) 2019-present  Instructure, Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as
published by the Free Software Foundation, either version 3 of the
License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.
```

## MDM Configurations

MDM Profile settings are saved in `UserDefaults.standard` and keyed by
`com.apple.configuration.managed`.
These logins are added to the list of previous logins on the start screen.

Use our `MDMManager` to observe changes such as managed logins.

You can test this locally with command line arguments.

`Scheme` > `Edit Scheme` > `Run` > `Arguments` > `Arguments Passed on Launch`

```
-com.apple.configuration.managed '<dict><key>enableLogin</key><true/><key>users</key><array><dict><key>host</key><string>canvas.instructure.com</string><key>username</key><string>student</string><key>password</key><string>Canvas2019</string></dict></array></dict>'
```

Change the `username`, `password`, and `host` to your test credentials. You can also add `host` and `authenticationProvider` strings to the top level dict to skip the "Find my school" screen during login.
