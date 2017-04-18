//
// Copyright (C) 2017-present Instructure, Inc.
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

class EditCoursesListPage {

  // MARK: Singleton

  static let sharedInstance = EditCoursesListPage()
  private init() {}

  // MARK: Elements

  // NOTE: Course element leak: multiple matches found
  private let doneButton = e.firstElement(e.selectBy(id: "done_button"))

  // MARK: - Assertions

  // MARK: - UI Actions
  func closePage(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_fromFile(file, line)

    doneButton.tap()
  }

  // NOTE: Course element leak: multiple matches found
  func selectActiveCourse(_ course:Course) -> GREYElementInteraction {
    let courseActiveId = "course_favorite_active_\(course.id)"
    let courseActiveElement = e.firstElement(e.selectBy(id: courseActiveId))
    return courseActiveElement
  }

  // NOTE: Course element leak: multiple matches found
  func selectHiddenCourse(_ course:Course) -> GREYElementInteraction {
    let courseHiddenId = "course_favorite_hidden_\(course.id)"
    let courseHiddenElement = e.firstElement(e.selectBy(id: courseHiddenId))
    return courseHiddenElement
  }

  // tap until active
  func assertCourseFavorited(_ course:Course, _ file: StaticString = #file, _ line: UInt = #line) {
    grey_fromFile(file, line)
    let courseActiveElement = selectActiveCourse(course)
    let courseHiddenElement = selectHiddenCourse(course)

    // is active element present?
    if courseActiveElement.exists() { return }
    courseHiddenElement.assertExists()

    let success = GREYCondition(name: "Waiting for favorite to activate", block: { _ in
      var ignoredError: NSError?
      courseHiddenElement.perform(grey_tap(), error: &ignoredError)
      return courseActiveElement.exists()
    }).wait(withTimeout: elementTimeout, pollInterval: elementPoll)

    if !success { courseActiveElement.assert(with: grey_notNil()) }
  }

  // tap until hidden
  func assertCourseUnfavorited(_ course:Course, _ file: StaticString = #file, _ line: UInt = #line) {
    grey_fromFile(file, line)
    let courseActiveElement = selectActiveCourse(course)
    let courseHiddenElement = selectHiddenCourse(course)

    if courseHiddenElement.exists() { return }
    courseActiveElement.assertExists()

    let success = GREYCondition(name: "Waiting for favorite to hide", block: { _ in
      var ignoredError: NSError?
      courseActiveElement.perform(grey_tap(), error: &ignoredError)
      return courseHiddenElement.exists()
    }).wait(withTimeout: elementTimeout, pollInterval: elementPoll)

    if !success { courseHiddenElement.assert(with: grey_notNil()) }
  }

  func assertHasCourses(_ courseArray:[Course], _ file: StaticString = #file, _ line: UInt = #line) {
    grey_fromFile(file, line)
    for course in courseArray {
      let courseHidden = "course_favorite_hidden_\(course.id)"
      let courseActive = "course_favorite_active_\(course.id)"

      // NOTE: Course element leak: multiple matches found
      guard let foundCourse = EarlGrey.select(elementWithMatcher: grey_anyOfMatchers([grey_accessibilityID(courseHidden), grey_accessibilityID(courseActive)])).atIndex(0) else {
        fatalError("course not found! \(course.id)")
      }
      foundCourse.assertExists()
    }
  }
}
