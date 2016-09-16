import XCTest
import SoAutomated

@available(iOS 9.0, *)
class LoginPage: TestPage {

    //# MARK: - Navigation Controller Element Locator Properties

    var cancelButton: XCUIElement {
        return app.buttons["cancelLoginButton"] // id
    }

    var navigationBarTitle: XCUIElement  {
        return app.staticTexts[UserProfile.domain] // label
    }

    //# MARK: - Webview Log In Form Element Locators

    var emailField: XCUIElement {
        return app.textFields["Email"] // label
    }

    var passwordField: XCUIElement {
        return app.secureTextFields["Password"] // label
    }

    var loginButton: XCUIElement {
        return app.buttons["Log In"] // label
    }

    var passwordResetButton: XCUIElement {
        return app.staticTexts["I don't know my password"] // label
    }

    //# MARK: - Webview Password Reset Form Element Locators

    var instructions: XCUIElement {
        return app.staticTexts["Enter your Email and we'll send you a link to change your password."] // label
    }

    var requestPasswordButton: XCUIElement {
        return app.buttons["Request Password"] // label
    }

    var backToLogin: XCUIElement {
        return app.staticTexts["Back to Login"] // label
    }

    //# MARK: - Log In Error Message Element Locators

    var noPasswordError: XCUIElement {
        return app.staticTexts["No password was given"] // label
    }

    var incorrectError: XCUIElement {
        return app.staticTexts["Incorrect username and/or password"] // label
    }

    //# MARK: - Assertion Helpers

    func assertNavigationController(domain: String = DomainPickerPage.defaultDomain, file: String = #file, _ line: UInt = #line) {
        assertExists(app.staticTexts[domain], file, line)
        assertExists(cancelButton, file, line)
    }

    func assertForm(file: String = #file, _ line: UInt = #line) {
        assertExists(emailField, file, line)
        assertExists(passwordField, file, line)
        assertExists(loginButton, file, line)
        assertExists(passwordResetButton, file, line)
    }

    func assertPage(domain: String = DomainPickerPage.defaultDomain, file: String = #file, _ line: UInt = #line) {
        assertNavigationController(domain, file: file, line)
        assertForm(file, line)
    }

    func assertIncorrectUserOrPasswordError(file: String = #file, _ line: UInt = #line) {
        assertExists(incorrectError, file, line)
    }

    func assertResetForm(file: String = #file, _ line: UInt = #line) {
        assertExists(instructions, file, line)
        assertExists(emailField, file, line)
        assertExists(requestPasswordButton, file, line)
        assertExists(backToLogin, file, line)
    }

    func assertNavigationBarTitle(file: String = #file, _ line: UInt = #line) {
        assertExists(navigationBarTitle, file, line)
    }

    //# MARK: - UI Action Helpers

    func login(username: String, _ password: String) {
        typeText(emailField, username)
        typeText(passwordField, password)
        tap(loginButton)
    }

    func close() {
        tap(cancelButton)
    }

    func openPasswordReset() {
        tap(passwordResetButton)
    }

    func closePasswordReset() {
        tap(backToLogin)
    }
}