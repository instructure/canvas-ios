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

class CourseSettingsPage {

    // MARK: Singleton

    static let sharedInstance = CourseSettingsPage()
    private init() {}

    // MARK: Elements

    private let cancelButton = e.selectBy(id: "screen.dismiss")
    private let doneButton = e.selectBy(id: "course-settings.done-btn")
    private let courseNameLabel = e.selectBy(id: "course-settings.name-lbl")
    private let courseNameTextbox = e.selectBy(id: "course-settings.name-input-textbox")
    private let setHomeLabel = e.selectBy(id: "course-settings.set-home-lbl")
    private let homePicker = e.selectBy(id: "course-settings.toggle-home-picker")

    private let navBarTitleView = e.selectBy(matchers: [grey_accessibilityLabel("Course Settings"),
                                                        grey_accessibilityTrait(UIAccessibilityTraitHeader),
                                                        grey_accessibilityTrait(UIAccessibilityTraitStaticText)])

    // MARK: - Assertions

    func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        // navBarTitleView.assertExists() TODO: fix me
        cancelButton.assertExists()
        doneButton.assertExists()
        courseNameLabel.assertExists()
        setHomeLabel.assertExists()
        courseNameTextbox.assertExists()
        homePicker.assertExists()
    }

    // MARK: - UI Actions

    func dismissToCourseBrowserPage(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        doneButton.tapUntilHidden()
    }
}
