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

class DashboardPage: PageObject {

  // Mark: - Page Objects

  private static var userCarousel: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("user_selection_carousel"))
  }

  private static var userNameLabel: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("student_name_label"))
  }

  private static var settingsButton: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("settings_button"))
  }

  private static var coursesTab: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("courses_tab_button"))
  }

  private static var weekTab: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("week_tab_button"))
  }

  private static var alertsTab: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("alerts_tab_button"))
  }

  static func uniquePageElement() -> GREYElementInteraction {
    return settingsButton
  }

  // Mark: - Assertion Helpers

  static func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    waitForPageToLoad()
    userCarousel.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    userNameLabel.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    settingsButton.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    coursesTab.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    weekTab.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    alertsTab.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
  }

  // Mark: - UI Action Helpers

  static func tapSettingsButton(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    settingsButton.perform(grey_tap())
  }

  static func tapCoursesTab(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    coursesTab.perform(grey_tap())
  }

  static func tapWeekTab(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    weekTab.perform(grey_tap())
  }

  static func tapAlertsTab(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    alertsTab.perform(grey_tap())
  }
}
