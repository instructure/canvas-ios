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

class GettingStartedPage: PageObject {

  // Mark: - Page Objects

  private static var getStartedLabel: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("get_started_label"))
  }

  private static var addStudentButton: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("add_student_button"))
  }

  private static var logoutButton: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("logout_button"))
  }

  static func uniquePageElement() -> GREYElementInteraction {
    return getStartedLabel
  }

  // Mark: - Assertion Helpers

  static func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)


    getStartedLabel.assert(with: grey_sufficientlyVisible())
    addStudentButton.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    logoutButton.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
  }

  // Mark: - UI Action Helpers

  static func tapLogoutButton(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    logoutButton.perform(grey_tap())
  }
}
