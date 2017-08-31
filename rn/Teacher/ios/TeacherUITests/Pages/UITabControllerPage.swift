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
import EarlGrey

class UITabBarControllerPage {
    
    // MARK: Elements

    private let coursesTabButton = e.selectBy(id: "tab-bar.courses-btn")
    private let inboxTabButton = e.selectBy(id: "tab-bar.inbox-btn")
    private let profileTabButton = e.selectBy(id: "tab-bar.profile-btn")

    // MARK: - Assertions

    func assertUITabBar(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        coursesTabButton.assertExists()
        inboxTabButton.assertExists()
        profileTabButton.assertExists()
    }

    // MARK: - UI Actions

    func openCourseTab(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        coursesTabButton.tap()
    }

    func openInboxTab(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        inboxTabButton.tap()
    }

    func openProfileTab(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        profileTabButton.tap()
    }
}
