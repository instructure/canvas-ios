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

class CourseListPage {

  // MARK: Singleton

  static let sharedInstance = CourseListPage()
  private init() {}

  let seeAllCoursesButton = e.selectBy(id: "course-list.see-all-btn")

  // Mark: - Assertions

  func assertCourseExists(_ course: Course, _ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    e.selectBy(id: course.courseCode).assertExists()
  }

  // Mark: - UI Actions

  func openAllCoursesPage(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    seeAllCoursesButton.tap()
  }
}
