//
//  CanvasLoginPage.swift
//  Teacher
//
//  Created by Taylor Wilson on 3/20/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import SoGrey
import EarlGrey

class CanvasLoginPage: PageObject {

  private static var emailField: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityValue("Email"))
  }

  private static var passwordField: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityValue("Password"))
  }

  private static var logInButton: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityLabel("Log In"))
  }

  private static var authorizeButton: GREYElementInteraction {
    return EarlGrey.select(elementWithMatcher: grey_accessibilityLabel("Authorize"))
  }

  static func uniquePageElement() -> GREYElementInteraction {
    return emailField
  }

  static func assertPageObjects(_ file: StaticString = #file, _ line: UInt = #line) {
    // todo
  }

  static func logIn(teacher: CanvasUser) {
    waitForPageToLoad()

    // a really bad hack to get user creds into the web form
    emailField.perform(grey_tap())
    emailField.perform(grey_typeText(teacher.loginId))

    // passwordField.perform(grey_typeText(teacher.password)) doesn't work reliably,
    // this hack makes it work reliably :( 
    logInButton.perform(grey_tap())
    
    passwordField.perform(grey_tap())
    passwordField.perform(grey_typeText(teacher.password))
    dismissKeyboard()

    logInButton.perform(grey_tap())
    authorizeButton.perform(grey_tap())
  }
}
