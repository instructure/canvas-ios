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
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("first_name_field"))
  }

  private static var lastNameField: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("last_name_field"))
  }

  private static var emailField: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("email_field"))
  }

  private static var passwordField: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("password_field"))
  }

  private static var confirmPasswordField: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("confirm_password_field"))
  }

  private static var createAccountButton: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("primary_action_button"))
  }

  private static var cancelButton: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("cancel_button"))
  }

  static func uniquePageElement() -> GREYElementInteraction {
    return confirmPasswordField
  }

  // Mark: - Assertion Helpers

  static func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    dismissKeyboard()
    firstNameField.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    lastNameField.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    emailField.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    passwordField.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    confirmPasswordField.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    createAccountButton.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    cancelButton.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
  }

  static func assertCreateAccountButtonDisabled(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    createAccountButton.assert(with: grey_not(grey_enabled()))
  }

  static func assertCreateAccountButtonEnabled(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    createAccountButton.assert(with: grey_enabled())
  }

  // Mark: - UI Action Helpers

  static func enterCredentials(_ parent: Parent, _ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    firstNameField.perform(grey_replaceText(parent.firstName))
    lastNameField.perform(grey_replaceText(parent.lastName))
    emailField.perform(grey_replaceText(parent.username))
    passwordField.perform(grey_replaceText(parent.password))
    confirmPasswordField.perform(grey_replaceText(parent.password))
  }

  static func randomizePasswordField(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    passwordField.perform(grey_replaceText(NSUUID().uuidString))
  }

  static func clearConfirmPasswordField(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    confirmPasswordField.perform(grey_replaceText(""))
  }

  static func tapCancelButton(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    dismissKeyboard()
    cancelButton.perform(grey_tap())
  }

  static func clearForm(_ field: String, _ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    switch(field) {
    case "firstName":
      firstNameField.perform(grey_replaceText(""))
    case "lastName":
      lastNameField.perform(grey_replaceText(""))
    case "email":
      emailField.perform(grey_replaceText(""))
    case "password":
      passwordField.perform(grey_replaceText(""))
    case "confirmPassword":
      confirmPasswordField.perform(grey_replaceText(""))
    default:
      break
    }
  }
}
