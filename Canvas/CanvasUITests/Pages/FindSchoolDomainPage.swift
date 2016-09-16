import XCTest
import SoAutomated

@available(iOS 9.0, *)
class FindSchoolDomainPage: TestPage {

    //# MARK: - Navigation Controller Element Locator Properties

    var findDomainTitle: XCUIElement {
        return app.staticTexts["Help"] // label
    }

    var doneButton: XCUIElement {
        return app.buttons["Done"] // label
    }

    //# MARK: - Webview H1 Tag Locator

    var webviewH1Tag: XCUIElement {
        return app.staticTexts["How do I find my institution's URL to access Canvas apps on my mobile device?"] // label
    }

    //# MARK: - Assertion Helpers

    func assertNavigationController(file: String = #file, _ line: UInt = #line) {
        assertExists(findDomainTitle, file, line)
        assertExists(doneButton, file, line)
    }

    func assertWebview(file: String = #file, _ line: UInt = #line) {
        assertExists(webviewH1Tag, file, line)
    }

    func assertPage(file: String = #file, _ line: UInt = #line) {
        assertNavigationController(file, line)
        assertWebview(file, line)
    }

    //# MARK: - UI Action Helpers

    func close() {
        tap(doneButton)
    }
}
