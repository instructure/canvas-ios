# Instructure iOS

### Please Note:
- This repository will be updated frequently with *breaking* changes. Fork with caution.

## Prerequisites:
- Xcode 9.3
- macOS 10.13.4
- [Nodejs 8.11.1](https://nodejs.org/)
- [Yarn 1.5.1](https://github.com/yarnpkg/yarn)
- [Cocoapods 1.5.0](https://cocoapods.org)

## Installation
- `./setup`
- Add required license keys in the secrets.plist
- If you want to use PSPDFKit, you will need to modify the Podfile to include your own PSPDFKit podspec url in addition to adding the license to secrets.plist.
- If you wish to use Google Analytics in Canvas, follow [these directions](http://bit.ly/2dPsV9D) to add a GoogleService-Info.plist to Canvas/Canvas/Shrug/GoogleService-Info.plist

## Apps

App | Description
--- | ---
[Student][student] | Used by Students all over the world to be smarter, go faster, and do more.
[Teacher][teacher] | Used by Students all over the world to be smarter, go faster, and do more.
[Parent][parent] | Used by Students all over the world to be smarter, go faster, and do more.

## Open Source Licenses Used

#### Our applications are licensed under the GPLv3 License.

```
Copyright (C) 2016 - present  Instructure, Inc.

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
Copyright (C) 2016 - present Instructure, Inc.

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

[student]: https://itunes.apple.com/us/app/canvas-student/id480883488?mt=8
[teacher]: https://itunes.apple.com/us/app/canvas-teacher/id1257834464?mt=8
[parent]: https://itunes.apple.com/us/app/canvas-parent/id1097996698?mt=8
