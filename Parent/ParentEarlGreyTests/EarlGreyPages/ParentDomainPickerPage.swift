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
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("email_field"))
  }

  private static var passwordField: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("password_field"))
  }

  private static var loginButton: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("primary_action_button"))
  }

  private static var createAccountButton: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("create_account_button"))
  }

  private static var forgotPasswordButton: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityID("forgot_password_button"))
  }

  static func uniquePageElement() -> GREYElementInteraction {
    return forgotPasswordButton
  }

  // Mark: - Assertion Helpers

  static func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    emailField.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    passwordField.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    loginButton.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    createAccountButton.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
    forgotPasswordButton.assert(with: grey_allOfMatchers([grey_sufficientlyVisible(), grey_interactable()]))
  }

  static func assertLoginButtonDisabled(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    loginButton.assert(with: grey_not(grey_enabled()))
  }

  static func assertLoginButtonEnabled(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    loginButton.assert(with: grey_enabled())
  }

  // Mark: - UI Action Helpers

  static func tapCreateAccount(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    createAccountButton.perform(grey_tap())
  }

  static func tapForgotPassword(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    forgotPasswordButton.perform(grey_tap())
  }

  static func enterCredentials(_ parent: Parent, _ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    emailField.perform(grey_replaceText(parent.username))
    passwordField.perform(grey_replaceText(parent.password))
  }

  static func loginAs(_ parent: Parent, _ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    enterCredentials(parent)
    loginButton.perform(grey_tap())
  }

  static func clearPasswordField(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    passwordField.perform(grey_replaceText(""))
  }

  static func clearEmailField(_ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    emailField.perform(grey_replaceText(""))
  }
}
