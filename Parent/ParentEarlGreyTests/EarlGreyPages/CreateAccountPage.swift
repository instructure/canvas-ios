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

class CreateAccountPage: PageObject {

  // Mark: - Page Objects

  private static var firstNameField: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("first_name_field"))
  }

  private static var lastNameField: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("last_name_field"))
  }

  private static var emailField: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("email_field"))
  }

  private static var passwordField: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("password_field"))
  }

  private static var confirmPasswordField: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("confirm_password_field"))
  }

  private static var createAccountButton: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("primary_action_button"))
  }

  private static var cancelButton: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("cancel_button"))
  }

  static func uniquePageElement() -> GREYElementInteraction {
    return confirmPasswordField
  }

  // Mark: - Assertion Helpers

  static func assertPageObjects(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    dismissKeyboard()
    firstNameField.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    lastNameField.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    emailField.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    passwordField.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    confirmPasswordField.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    createAccountButton.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    cancelButton.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
  }

  static func assertCreateAccountButtonDisabled(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    createAccountButton.assertWithMatcher(grey_not(grey_enabled()))
  }

  static func assertCreateAccountButtonEnabled(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    createAccountButton.assertWithMatcher(grey_enabled())
  }

  // Mark: - UI Action Helpers

  static func enterCredentials(parent: CanvasParent, file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    firstNameField.performAction(grey_replaceText(parent.firstName))
    lastNameField.performAction(grey_replaceText(parent.lastName))
    emailField.performAction(grey_replaceText(parent.username))
    passwordField.performAction(grey_replaceText(parent.password))
    confirmPasswordField.performAction(grey_replaceText(parent.password))
  }

  static func randomizePasswordField(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    passwordField.performAction(grey_replaceText(NSUUID().UUIDString))
  }

  static func clearConfirmPasswordField(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    confirmPasswordField.performAction(grey_replaceText(""))
  }

  static func tapCancelButton(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    dismissKeyboard()
    cancelButton.performAction(grey_tap())
  }

  static func clearForm(field: String, file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    switch(field) {
    case "firstName":
      firstNameField.performAction(grey_replaceText(""))
    case "lastName":
      lastNameField.performAction(grey_replaceText(""))
    case "email":
      emailField.performAction(grey_replaceText(""))
    case "password":
      passwordField.performAction(grey_replaceText(""))
    case "confirmPassword":
      confirmPasswordField.performAction(grey_replaceText(""))
    default:
      break
    }
  }
}
