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

class CoursesTabPage: PageObject {

  // Mark: - Page Objects

  private static var emptyListView: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("courses_empty_view"))
  }

  private static func courseCell(_ atRow: Int) -> GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("course_cell_\(atRow)"))
  }

  static func uniquePageElement() -> GREYElementInteraction {
    return emptyListView
  }

  // Mark: - Assertion Helpers

  static func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    emptyListView.assert(with: grey_sufficientlyVisible())
  }

  // Mark: - UI Action Helpers

  static func tapCourseCell(_ row: Int = 0, _ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    courseCell(row).perform(grey_tap())
  }
}
