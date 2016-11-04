# Instructure iOS

## Prerequisites:
- Xocde 8
- macOS 10.12
- [Cocoapods 1.0.1](https://cocoapods.org)
- [Carthage 0.18](https://github.com/Carthage/Carthage)

## Installation
- `pod install`
- `carthage checkout --no-use-binaries`
- Add frameworks to the ExternalFrameworks directory. (See ExternalFrameworks/README.md)
- Add required license keys in the keys.plist
- If you wish to use Google Analytics in Canvas, follow [these directions](http://bit.ly/2dPsV9D) to add a GoogleService-Info.plist to Canvas/Canvas/Shrug/GoogleService-Info.plist

## Apps

App | Description
--- | ---
[Canvas][canvas]           | Used by Students all over the world to be smarter, go faster, and do more. 
[SpeedGrader][speedgrader] | Used by Teachers all over the work to grade at lightning speeds.

## Instructure Frameworks
A collection of frameworks that are specific to Instructure

Framework | Description
--- | ---
AssignmentKit   | Models assignments within Canvas. This includes closely related features such as Submissions and Rubrics. Included utilities for refreshing and aggregating its model objects.
CalendarKit	    | Models CalendarEvents within Canvas includes utilities for refreshing and aggregating collections of calendar events.
DiscussionKit	| Models Discussions includes utilities for fetching and aggregating discussions and discussion topics.
EnrollmentKit	| Models Courses, Groups and Tabs (used for navigation within a course or group). EnrollmentKit also includes an in-memory store for easy access to the logged in user's enrollments.
FileKit        	| Models Files and provides utilities for refreshing, aggregating and uploading files.
Icons 			| Contains the common set of icons used throughout our mobile apps.
Keymaster 		| Provides a common UI for logging into Canvas as well as searching for schools. Also includes keychain storage and retreval of Canvas sessions.
MediaKit 		| Models media recording and commenting.
MessageKit 		| Models conversation messages within Canvas. Includes utilities for fetching and aggregating conversations and conversation messages.
NotificationKit | Includes utilities for managing the user's notification preferences including push notifications.
Pages 		    | Models Canvas wiki pages and includes utilities for fetching and aggregating pages.
Peeps 			| Models Users and their enrollments within Canvas. Includes utilities for fetching and aggregating Users and their Enrollments.
Quizzes 	    | Contains code for taking Quizzes.
SoAnnotated 	| Supports annotating PDFs with PSPDFKit.
SoEdventurous 	| Contains code for Modules and Mastery Paths. Includes utilties for fetching and aggregating Modules and Module Items.
SoProgressive 	| Includes code to publish and subscribe to course progress. This framework exists to decouple consumers of user progress, such as Modules, from frameworks such as AssignmentKit and Quizzes which contain code to allow the student to make progress within a course.
SoSupportive 	| Includes code allowing users to submit support requests directly from the apps.
Todo 			| Models the Canvas Todo List. Includes code to fetch and aggregate Todo Items.
TooLegit 		| Canvas core networking framework. This framework contains common networking code and utilities for fetching data from the Canvas API. Most of the other frameworks depend on TooLegit for its networking and Session capabilities.

## General Frameworks
A collection of frameworks that are general purpose

Framework | Description
--- | ---
SoLazy 			| A collection of utilties and extensions that simplify tasks or provide a more Swift friendly interface to Apple APIs. 
SoPersistent 	| A powerhouse of persistence goodness. SoPersistent is based on CoreData and provides a unified Collection interface around NSFetchedResultsController. It also contains table and collection view controllers that exploit these collections. These utilities are optimized for reuse and customization.
SoPretty        | A collection of UI utilitites, custom views, and colors used throughout Canvas.
WhizzyWig 		| Views for displaying and authoring rich text (html) content. Because we let our users do _anything_ they want.
SoGrey          | Automated testing with [EarlGrey](https://github.com/google/EarlGrey)

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

#### Our Modules are licensed under the Apache v2 License.

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

[canvas]: https://itunes.apple.com/us/app/canvas-by-instructure/id480883488?mt=8
[speedgrader]: https://itunes.apple.com/us/app/speedgrader/id418441195?mt=8