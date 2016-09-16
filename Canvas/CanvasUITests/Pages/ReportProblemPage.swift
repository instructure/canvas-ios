import XCTest
import SoAutomated

@available(iOS 9.0, *)
class ReportProblemPage: TestPage {

    //# MARK: - Navigation Controller Element Locators

    var cancelButton: XCUIElement {
        return app.buttons["cancelTicketButton"] // id
    }

    var problemTitle: XCUIElement {
        return app.staticTexts["Report a problem"] // label
    }

    var featureTitle: XCUIElement {
        return app.staticTexts["Request a feature"] // label
    }

    var backToProblemButton: XCUIElement {
        return app.buttons["Report a problem"] // label
    }

    var backToFeatureButton: XCUIElement {
        return app.buttons["Request a feature"] // label
    }

    var sendButton: XCUIElement {
        return app.buttons["sendTicketButton"] // id
    }

    //# MARK: - Form Element Locators

    var subjectLabel: XCUIElement {
        return app.staticTexts["Subject:"] // label
    }

    var subjectField: XCUIElement {
        return app.textFields["ticketSubjectTextField"] // id
    }

    var impactLabel: XCUIElement {
        return app.staticTexts["Impact:"] // label
    }

    var impactOptions: XCUIElement {
        return app.buttons["ticketImpactButton"] // id
    }

    var description: XCUIElement {
        return app.staticTexts["ticketBodyTextView"] // id
    }

    //# MARK: - Impact Level Options Locators

    var impactTitle: XCUIElement {
        return app.staticTexts["Impact Level"] // label
    }

    var casualCell: XCUIElement {
        return app.cells["ticketImpactCasualCell"] // id
    }

    var needHelpCell: XCUIElement {
        return app.cells["ticketImpactNeedHelpCell"] // id
    }

    var brokenCell: XCUIElement {
        return app.cells["ticketImpactSomethingBrokenCell"] // id
    }

    var stuckCell: XCUIElement {
        return app.cells["ticketImpactStuckCell"] // id
    }

    var emergencyCell: XCUIElement {
        return app.cells["ticketImpactEmergencyCell"] // id
    }

    //# MARK: - Assertion Helpers

    func assertNavigationController(titleText: XCUIElement? = nil, file: String = #file, _ line: UInt = #line) {
        // default title is "Report a Problem"
        if let title = titleText {
            assertExists(title, file, line)
        } else {
            assertExists(problemTitle, file, line)
        }
        assertExists(cancelButton, file, line)

        // send button is not enabled until text is entered
        assertDisabled(sendButton, file, line)
    }

    func assertFeatureNavigationController(file: String = #file, _ line: UInt = #line) {
        assertNavigationController(featureTitle, file: file, line)
    }

    func assertImpactNavigationController(backButton: XCUIElement? = nil, file: String = #file, _ line: UInt = #line) {
        // default back button is "Report a Problem"
        if let back = backButton {
            assertExists(back, file, line)
        } else {
            assertExists(backToProblemButton, file, line)
        }
        assertExists(impactTitle, file, line)
    }

    func assertFeatureImpactNavigationController(file: String = #file, _ line: UInt = #line) {
        assertImpactNavigationController(backToFeatureButton, file: file, line)
    }

    func assertImpactOptions(file: String = #file, _ line: UInt = #line) {
        assertExists(casualCell, file, line)
        assertExists(needHelpCell, file, line)
        assertExists(brokenCell, file, line)
        assertExists(stuckCell, file, line)
        assertExists(emergencyCell, file, line)
        XCTAssertTrue(app.tables.cells.count == 5)
    }

    func assertForm(file: String = #file, _ line: UInt = #line) {
        assertExists(subjectLabel, file, line)
        assertExists(subjectField, file, line)
        assertExists(impactLabel, file, line)
        assertExists(impactOptions, file, line)
        assertExists(description, file, line)
    }

    //# MARK: - UI Action Helpers

    func openImpactOptions() {
        tap(impactOptions)
    }

    func closeImpactOptions(backButton: XCUIElement? = nil) {
        if let back = backButton {
            tap(back)
        } else {
            tap(backToProblemButton)
        }
    }

    func closeFeatureImpactOptions() {
        closeImpactOptions(backToFeatureButton)
    }
}
