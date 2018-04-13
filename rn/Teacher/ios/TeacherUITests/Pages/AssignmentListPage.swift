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

class AssignmentListPage  {

    // MARK: Singleton

    static let sharedInstance = AssignmentListPage()
    private let tabBarController = TabBarControllerPage.sharedInstance
    private init() {}

    // MARK: Elements
    private let navBarTitleView = e.selectBy(id: "assignment-list.nav-bar-title-view")
    private let containerView = e.selectBy(id: "assignment-list.container-view")
    private let filterHeaderView = e.selectBy(id: "assignment-list.filter-header-view")
    private let filterTitleLabel = e.selectBy(id: "assignment-list.filter-title-lbl")

    // MARK: - Helpers

//    private func backButton(_ course: Course) -> GREYElementInteraction {
//        let backButtonElement = EarlGrey.select(
//            elementWithMatcher: grey_allOf([grey_accessibilityLabel(course.courseCode),
//                                            grey_accessibilityTrait(UIAccessibilityTraitButton)]))
//        return backButtonElement
//    }

    private func assignmentCell(_ assignment: Soseedy_Assignment) -> GREYInteraction {
        return e.selectBy(id: "assignment-list.assignment-list-row.cell-\(assignment.id)")
    }

    private func assignmentCellSubtitleLabel(_ assignment: Soseedy_Assignment) -> GREYInteraction {
        return e.selectBy(id: "assignment-list.assignment-list-row.cell-\(assignment.id)-subtitle-lbl")
    }

    // MARK: - Assertions

//    func assertPageObjects(_ course: Course, _ file: StaticString = #file, _ line: UInt = #line) {
//        grey_fromFile(file, line)
//        tabBarController.assertTabBarItems()
//        backButton(course).assertExists()
//        navBarTitleView.assertExists()
//        filterHeaderView.assertExists()
//        containerView.assertExists()
//        filterTitleLabel.assertExists()
//    }

    func assertHasAssignment(_ assignment: Soseedy_Assignment, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        assignmentCell(assignment).assertExists()
    }

    func assertHasDueDate(_ assignment: Soseedy_Assignment, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        assignmentCellSubtitleLabel(assignment).assertExists()
    }

    // MARK: - UI Actions

//    func dismissToCourseBrowserPage(_ course: Course, _ file: StaticString = #file, _ line: UInt = #line) {
//        grey_fromFile(file, line)
//        backButton(course).tapUntilHidden()
//    }

    func openAssignmentDetailsPage(_ assignment: Soseedy_Assignment, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        assignmentCell(assignment).tapUntilHidden()
    }
}
