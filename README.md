# Canvas iOS Apps

- [Student](https://itunes.apple.com/us/app/canvas-student/id480883488?mt=8)
- [Teacher](https://itunes.apple.com/us/app/canvas-teacher/id1257834464?mt=8)
- [Parent](https://itunes.apple.com/us/app/canvas-parent/id1097996698?mt=8)


## Getting Started on Development

You will need the following tools installed beforehand:

- [Carthage](https://github.com/Carthage/Carthage#installing-carthage)
- [Cocoapods](https://cocoapods.org)
- [SwiftLint](https://github.com/realm/SwiftLint#installation)
- [yarn](https://yarnpkg.com/en/docs/install#mac-stable)

```sh
brew install carthage swiftlint yarn
gem install cocoapods
```

Then you can setup the repo:

```sh
git clone git@github.com:instructure/canvas-ios.git
cd canvas-ios
./setup.sh
```

The `setup.sh` script should take care of installing additional dependencies from Carthage, Cocoapods, and yarn.

### Carthage

Carthage is used to checkout the source code of the EarlGrey 2 dependency.
EG2 is included via source because Carthage doesn't support building static libraries.

PSPDFKit is also installed via Carthage.

- `carthage update` Updates `Cartfile.resolved` with new dependencies
- `carthage bootstrap` Fetches dependencies defined in `Cartfile.resolved`

### Secrets

Any static keys, tokens, passwords, or other secrets that need to be available in the app bundle should be added as a case to `Secret.swift`.

The secrets necessary for a particular build are generated as data assets using a script.

```sh
yarn secrets "studentPSPDFKitLicense=token1" "teacherPSPDFKitLicense=token2"
```

You will need to purchase PSPDFKitLicenses to distribute custom apps. Instructure's licenses are only used for official builds and are not included in the repository.

### Firebase Analytics

If you wish to use Firebase Analytics in custom apps, you will need to populate the `GoogleService-Info.plist` for each app.


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

😬 One day React Native, Cocoapods, CanvasKit and other old frameworks will be fully replaced by the swift architecture (Core + StudentReborn). Eventually. Hopefully. 🤞


## Using the Canvas Apps

### How to connect to a local canvas instance
- Modify the contents of preload-account-info.plist (it's at the root of the repo)
  * See How To Generate a Developer Key section below
  * `client_id` is the `ID` of a generated Developer Key
  * `client_secret` is the `Key` of the generated Developer Key
- Build and run the app locally
- On the login page, your local canvas instance will appear in the top left corner of the screen

### How to Generate a Developer Key
- Visit `web.canvas.docker/accounts/self/developer_keys` (replace `web.canvas.docker`
with your local instance
- Click `+ Developer Key`
- Give it a name and the following fields:
  * `Redirect URI (Legacy)`: `https://canvas/login`
  * `Redirect URIs` (separated by new lines):
    - https://canvas/login
    - canvas-courses://canvas/login
    - canvas-teacher://canvas/login
    - canvas-parent://canvas/login

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

#### Our applications are licensed under the GPLv3 License.

```
Copyright (C) 2016-present  Instructure, Inc.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3 of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
```

#### Our frameworks are licensed under the Apache v2 License.

```
Copyright (C) 2016-present Instructure, Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
