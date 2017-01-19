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

class CoursePage: PageObject {

  // Mark: - Page Objects

  private static var closeButton: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("close_button"))
  }

  private static func courseLabel(_ name: String) -> GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityLabel(name))
  }

  private static var lastWeekButton: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("last_week_button"))
  }

  private static var weekHeaderLabel: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("week_header_label"))
  }

  private static var nextWeekButton: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("next_week_button"))
  }

  private static var emptyWeekView: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("week_empty_view"))
  }

  static func uniquePageElement() -> GREYElementInteraction {
    return emptyWeekView
  }

  // Mark: - Assertion Helpers

  static func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    closeButton.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    lastWeekButton.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    weekHeaderLabel.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    nextWeekButton.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
  }

  static func assertEmptyWeekView(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    emptyWeekView.assert(with: grey_sufficientlyVisible())
  }
}
