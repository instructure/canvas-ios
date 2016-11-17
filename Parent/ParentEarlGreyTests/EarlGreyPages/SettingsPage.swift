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

class SettingsPage: PageObject {

  // Mark: - Page Objects

  private static var closeButton: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("close_button"))
  }

  private static var settingsTitle: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("Settings"))
  }

  private static var helpMenuButton: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("help_button"))
  }

  private static var helpMenuMessage: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityLabel("How can we help?"))
  }

  private static var helpGuide: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_allOfMatchers(
      grey_accessibilityLabel("Help Guide"),
      grey_kindOfClass(Class.UIAlertControllerActionView)))
  }

  private static var helpShareLove: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_allOfMatchers(
      grey_accessibilityLabel("Share Some Love"),
      grey_kindOfClass(Class.UIAlertControllerActionView)))
  }

  private static var helpReportProblem: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_allOfMatchers(
      grey_accessibilityLabel("Report a Problem"),
      grey_kindOfClass(Class.UIAlertControllerActionView)))
  }

  private static var helpRequestFeature: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_allOfMatchers(
      grey_accessibilityLabel("Request a Feature"),
      grey_kindOfClass(Class.UIAlertControllerActionView)))
  }

  private static var helpOpenSourceComponents: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_allOfMatchers(
      grey_accessibilityLabel("Open Source Components"),
      grey_kindOfClass(Class.UIAlertControllerActionView)))
  }

  private static var helpCancelButton: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_allOfMatchers(
      grey_accessibilityLabel("Cancel"),
      grey_kindOfClass(Class.UIAlertControllerActionView)))
  }

  private static var addStudentButton: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("add_observee_button"))
  }

  private static var logoutButton: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("logout_button"))
  }

  private static func observeeAvatar(row: Int) -> GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("observee_avatar_\(row)"))
  }

  private static func observeeNameLabel(row: Int) -> GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("observee_name_\(row)"))
  }

  static func uniquePageElement() -> GREYElementInteraction {
    return addStudentButton
  }

  // Mark: - Assertion Helpers
  static func assertPageObjects(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    closeButton.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    settingsTitle.assertWithMatcher(grey_sufficientlyVisible())
    helpMenuButton.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    addStudentButton.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    logoutButton.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
  }

  static func assertHelpMenu(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    helpMenuMessage.assertWithMatcher(grey_sufficientlyVisible())
    helpGuide.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    helpShareLove.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    helpReportProblem.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    helpRequestFeature.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    helpOpenSourceComponents.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    helpCancelButton.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
  }

  static func assertObserveeCell(row: Int = 0, file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    observeeAvatar(row).assertWithMatcher(grey_sufficientlyVisible())
    observeeNameLabel(row).assertWithMatcher(grey_sufficientlyVisible())
  }

  //Mark: - UI Action Helpers
  static func tapHelpButton(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    helpMenuButton.performAction(grey_tap())
  }
}
