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

import SoGrey

class TabBarControllerPage {

    static let sharedInstance = TabBarControllerPage()
    private init() {}

    // MARK: Elements

    private let coursesTabButton = e.selectBy(id: "tab-bar.courses-btn")
    private let inboxTabButton = e.selectBy(id: "tab-bar.inbox-btn")

    // MARK: - Assertions

    func assertTabBarItems(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        coursesTabButton.assertExists()
        inboxTabButton.assertExists()
    }

    // MARK: - UI Actions

    func openCourseListPage(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        coursesTabButton.tap()
    }

    func openInboxPage(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        inboxTabButton.tap()
    }
}
