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

class CanvasLoginPage {

    // MARK: Singleton

    static let sharedInstance = CanvasLoginPage()
    private init() {}

    // MARK: Page Elements

    private let logInButton = e.selectBy(label: "Log In")
    private let authorizeButton = e.selectBy(label: "Authorize")

    private let EMAIL_FIELD_CSS = "input[name=\"pseudonym_session[unique_id]\"]";
    private let PASSWORD_FIELD_CSS = "input[name=\"pseudonym_session[password]\"]";
    private let LOGIN_BUTTON_CSS = "button[type=\"submit\"]";
    private let FORGOT_PASSWORD_BUTTON_CSS = "a[class=\"forgot-password flip-to-back\"]";
    private let AUTHORIZE_BUTTON_CSS = "button[type=\"submit\"]";

    // MARK: - UI Actions

//    func logIn(teacher: CanvasUser, _ file: StaticString = #file, _ line: UInt = #line) {
//        grey_fromFile(file, line)
//
//        logInButton.assertExists() // wait for webview to load
//
//        if let emailElement = DriverAtoms.findElement(locator: Locator.CSS_SELECTOR, value: EMAIL_FIELD_CSS) {
//            DriverAtoms.webKeys(element: emailElement, value: teacher.loginId)
//        }
//
//        if let passwordElement = DriverAtoms.findElement(locator: Locator.CSS_SELECTOR, value: PASSWORD_FIELD_CSS) {
//            DriverAtoms.webKeys(element: passwordElement, value: teacher.password)
//        }
//
//        logInButton.tap()
//        authorizeButton.tap()
//    }

    // tmp login to validate webdriver code
    func logInTmp(loginId: String, password: String, _ file: StaticString = #file, _ line: UInt = #line) {
        grey_fromFile(file, line)

        logInButton.assertExists() // wait for webview to load
        if let emailElement = DriverAtoms.findElement(locator: Locator.CSS_SELECTOR, value: EMAIL_FIELD_CSS) {
            DriverAtoms.webKeys(element: emailElement, value: loginId)
        }

        if let passwordElement = DriverAtoms.findElement(locator: Locator.CSS_SELECTOR, value: PASSWORD_FIELD_CSS) {
            DriverAtoms.webKeys(element: passwordElement, value: password)
        }
    }
}
