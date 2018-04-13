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

import EarlGrey
import SoSeedySwift

public class EditDashboardPage {

    // MARK: Singleton

    public static let sharedInstance = EditDashboardPage()
    private init() {}

    // MARK: Elements

    private let doneButton = e.selectBy(id: "screen.dismiss")

    // MARK: - Helpers

    private func navBarTitleView() -> GREYInteraction {
        let titleViewElement = EarlGrey.selectElement(
            with: grey_allOf([grey_accessibilityLabel("Edit Courses"),
                                            grey_accessibilityTrait(UIAccessibilityTraitHeader),
                                            grey_accessibilityTrait(UIAccessibilityTraitStaticText)]))
        return titleViewElement
    }

//    func selectFavoritedCourse(_ course: Course) -> GREYElementInteraction {
//        let courseIsFavoritedID = "edit-favorites.course-favorite.\(course.id)-favorited"
//        let courseIsFavoritedElement = e.selectBy(id: courseIsFavoritedID)
//        return courseIsFavoritedElement
//    }
//
//    func selectNotFavoritedCourse(_ course: Course) -> GREYElementInteraction {
//        let courseIsNotFavoritedID = "edit-favorites.course-favorite.\(course.id)-not-favorited"
//        let courseIsNotFavoritedElement = e.selectBy(id: courseIsNotFavoritedID)
//        return courseIsNotFavoritedElement
//    }

    // MARK: - Assertions

    public func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        // navBarTitleView().assertExists()
        doneButton.assertExists()
    }

//    func assertCourseIsFavorited(_ course: Course, _ file: StaticString = #file, _ line: UInt = #line) {
//        grey_fromFile(file, line)
//        let courseIsFavoritedElement = selectFavoritedCourse(course)
//        courseIsFavoritedElement.assertExists()
//    }
//
//    func assertCourseIsNotfavorited(_ course: Course, _ file: StaticString = #file, _ line: UInt = #line) {
//        grey_fromFile(file, line)
//        let courseIsNotFavoritedElement = selectNotFavoritedCourse(course)
//        courseIsNotFavoritedElement.assertExists()
//    }
//
    public func assertHasCourses(_ courses: [Soseedy_Course], _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)

        for course in courses {
            let courseIsFavoritedID = "edit-favorites.course-favorite.\(course.id)-favorited"
            let courseIsNotFavoritedID = "edit-favorites.course-favorite.\(course.id)-not-favorited"

            let courseElement = EarlGrey.selectElement(
                with: grey_anyOf([grey_accessibilityID(courseIsFavoritedID),
                                                grey_accessibilityID(courseIsNotFavoritedID)]))

            courseElement.assertExists()
        }
    }

    // MARK: - UI Actions

    public func dismissToFavoriteCoursesPage(_ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)
        doneButton.tapUntilHidden()
    }

//    func toggleFavoritedCourse(_ course: Course, _ file: StaticString = #file, _ line: UInt = #line) {
//        grey_fromFile(file, line)
//        let courseIsFavoritedElement = selectFavoritedCourse(course)
//        courseIsFavoritedElement.tap()
//    }
//
//    func toggleNotFavoritedCourse(_ course: Course, _ file: StaticString = #file, _ line: UInt = #line) {
//        grey_fromFile(file, line)
//        let courseIsNotFavoritedElement = selectNotFavoritedCourse(course)
//        courseIsNotFavoritedElement.tap()
//    }
}
