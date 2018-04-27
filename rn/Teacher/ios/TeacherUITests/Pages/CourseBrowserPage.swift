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
import SoSeedySwift

class CourseBrowserPage {

    // MARK: Singleton

    static let sharedInstance = CourseBrowserPage()
    private let tabBarController = TabBarControllerPage.sharedInstance
    private init() {}

    // MARK: Elements

    private let backButton = e.selectBy(matchers: [grey_accessibilityLabel("Back"),
                                                   grey_kindOfClass(Class.UIAccessibilityBackButtonElement)])
    private let editButton = e.selectBy(id: "course-details.navigation-edit-course-btn")
    private let assignmentsCell = e.selectBy(id: "courses-details.assignments-cell")
    private let titleLabel = e.selectBy(id: "course-details.title-lbl")
    private let subtitleLabel = e.selectBy(id: "course-details.subtitle-lbl")

    // MARK: Helpers

    private func navBarTitleView(_ course: Soseedy_Course) -> GREYInteraction {
        let titleViewElement = EarlGrey.selectElement(
            with: grey_allOf([grey_accessibilityLabel(course.courseCode),
                                            grey_accessibilityTrait(UIAccessibilityTraitHeader),
                                            grey_accessibilityTrait(UIAccessibilityTraitStaticText)]))
        return titleViewElement
    }

    // MARK: - Assertions

    func assertPageObjects(_ course: Soseedy_Course, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        tabBarController.assertTabBarItems()

        // TODO: What is wrong with navBarTitleView?
        // navBarTitleView(course).assertExists()

        backButton.assertExists()
        editButton.assertExists()
        titleLabel.assertExists()
        subtitleLabel.assertExists()
        assignmentsCell.assertExists()
    }

    // MARK: UI Actions

    func openCourseSettingsPage(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        editButton.tapUntilHidden()
    }

    func openAssignmentListPage(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        assignmentsCell.tapUntilHidden()
    }

    func dismissToFavoriteCoursesPage(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        backButton.tapUntilHidden()
    }
}
