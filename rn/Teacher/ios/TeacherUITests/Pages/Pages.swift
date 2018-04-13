//
// Copyright (C) 2016-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import XCTest
import SoGrey

extension XCTestCase {
    var allCoursesListPage: AllCoursesListPage { return AllCoursesListPage.sharedInstance }
    var assignmentDetailsPage: AssignmentDetailsPage { return AssignmentDetailsPage.sharedInstance }
    var assignmentListPage: AssignmentListPage { return AssignmentListPage.sharedInstance }
    var loginPage: LoginPage { return LoginPage.sharedInstance }
    var canvasLoginPage: CanvasLoginPage { return CanvasLoginPage.sharedInstance }
    var coursesListPage: CoursesListPage { return CoursesListPage.sharedInstance }
    var editDashboardPage: EditDashboardPage { return EditDashboardPage.sharedInstance }
    var courseBrowserPage: CourseBrowserPage { return CourseBrowserPage.sharedInstance }
    var courseSettingsPage: CourseSettingsPage { return CourseSettingsPage.sharedInstance }
    var inboxPage: InboxPage { return InboxPage.sharedInstance }
    var tabBarController: TabBarControllerPage { return TabBarControllerPage.sharedInstance }
}
