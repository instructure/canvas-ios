//
//  CanvasLoginPage.swift
//  Teacher
//
//  Created by Taylor Wilson on 3/20/17.
//  Copyright © 2017 Instructure. All rights reserved.
//

import SoGrey
import EarlGrey

class CanvasLoginPage {

  // MARK: Singleton

  static let sharedInstance = CanvasLoginPage()
  private init() {}

  // MARK: Page Elements

  let logInButton = e.selectBy(   label: "Log In")
  let authorizeButton = e.selectBy(   label: "Authorize")

  let EMAIL_FIELD_CSS = "input[name=\"pseudonym_session[unique_id]\"]";
  let PASSWORD_FIELD_CSS = "input[name=\"pseudonym_session[password]\"]";
  let LOGIN_BUTTON_CSS = "button[type=\"submit\"]";
  let FORGOT_PASSWORD_BUTTON_CSS = "a[class=\"forgot-password flip-to-back\"]";
  let AUTHORIZE_BUTTON_CSS = "button[type=\"submit\"]";

  // Mark: - UI Actions

  func logIn(teacher: CanvasUser, _ file: StaticString = #file, _ line: UInt = #line) {
    grey_invokedFromFile(file, line)

    logInButton.assertExists() // wait for webview to load

    if let emailElement = DriverAtoms.findElement(locator: Locator.CSS_SELECTOR, value: EMAIL_FIELD_CSS) {
      DriverAtoms.webKeys(element: emailElement, value: teacher.loginId)
    }

    if let passwordElement = DriverAtoms.findElement(locator: Locator.CSS_SELECTOR, value: PASSWORD_FIELD_CSS) {
      DriverAtoms.webKeys(element: passwordElement, value: teacher.password)
    }

    logInButton.tap()
    authorizeButton.tap()
  }
}
