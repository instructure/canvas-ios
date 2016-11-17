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

class ParentDomainPickerPage: PageObject {

  // Mark: - Page Objects

  private static var emailField: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("email_field"))
  }

  private static var passwordField: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("password_field"))
  }

  private static var loginButton: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("primary_action_button"))
  }

  private static var createAccountButton: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("create_account_button"))
  }

  private static var forgotPasswordButton: GREYElementInteraction {
    return EarlGrey().selectElementWithMatcher(grey_accessibilityID("forgot_password_button"))
  }

  static func uniquePageElement() -> GREYElementInteraction {
    return forgotPasswordButton
  }

  // Mark: - Assertion Helpers

  static func assertPageObjects(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    emailField.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    passwordField.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    loginButton.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    createAccountButton.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
    forgotPasswordButton.assertWithMatcher(grey_allOfMatchers(grey_sufficientlyVisible(), grey_interactable()))
  }

  static func assertLoginButtonDisabled(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    loginButton.assertWithMatcher(grey_not(grey_enabled()))
  }

  static func assertLoginButtonEnabled(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    loginButton.assertWithMatcher(grey_enabled())
  }

  // Mark: - UI Action Helpers

  static func tapCreateAccount(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    createAccountButton.performAction(grey_tap())
  }

  static func tapForgotPassword(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    forgotPasswordButton.performAction(grey_tap())
  }

  static func enterCredentials(parent: CanvasParent, file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    emailField.performAction(grey_replaceText(parent.username))
    passwordField.performAction(grey_replaceText(parent.password))
  }

  static func loginAs(parent: CanvasParent, file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    enterCredentials(parent)
    loginButton.performAction(grey_tap())
  }

  static func clearPasswordField(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    passwordField.performAction(grey_replaceText(""))
  }

  static func clearEmailField(file: String = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    emailField.performAction(grey_replaceText(""))
  }
}
