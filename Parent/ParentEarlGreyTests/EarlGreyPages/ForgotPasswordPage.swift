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

class ForgotPasswordPage: PageObject {

  // Mark: - Page Objects

  private static var emailField: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("email_field"))
  }

  private static var submitButton: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("primary_action_button"))
  }

  private static var cancelButton: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("cancel_button"))
  }

  static func uniquePageElement() -> GREYElementInteraction {
    return cancelButton
  }

  // Mark: - Assertion Helpers

  static func assertPageObjects(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    emailField.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    submitButton.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    cancelButton.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
  }

  static func assertSubmitButtonDisabled(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    submitButton.assertWithMatcher(grey_not(grey_enabled()))
  }

  static func assertSubmitButtonEnabled(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    submitButton.assertWithMatcher(grey_enabled())
  }

  // Mark: - UI Action Helpers

  static func tapCancel(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    cancelButton.performAction(grey_tap())
  }

  static func enterEmail(parent: CanvasParent, file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    emailField.performAction(grey_replaceText(parent.username))
  }
}
