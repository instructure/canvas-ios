import XCTest
import SoAutomated

@available(iOS 9.0, *)
class DomainPickerPage: TestPage {

    //# MARK: - Help Menu and Actionsheet Element Locator Properties

    var helpMenuButton: XCUIElement {
        return app.buttons["helpButton"] // id
    }

    var helpMenuTitle: XCUIElement {
        return app.staticTexts["Help Menu"] // label
    }

    var reportProblemButton: XCUIElement {
        return app.buttons["Report a Problem"] // label
    }

    var requestFeatureButton: XCUIElement {
        return app.buttons["Request a Feature"] // label
    }

    var findSchoolDomainButton: XCUIElement {
        return app.buttons["Find School Domain"] // label
    }

    var cancelButton: XCUIElement {
        return app.buttons["Cancel"] // label
    }

    //# MARK: - Canvas Logo Locator

    var canvasLogo: XCUIElement {
        return app.images["login_logo"] // id
    }

    //# MARK: - Domain Text Field and Connect Button Locators

    var schoolDomainField: XCUIElement {
        return app.textFields["domainPickerTextField"] // id
    }

    var schoolDomainButton: XCUIElement {
        return app.buttons["domainPickerSubmitButton"] // id
    }

    //# MARK: - Can't Find School Label and Help Label Locators

    var cantFindSchoolLabel: XCUIElement {
        return app.staticTexts["Can't find your school?"] // label
    }

    var tapForHelpLabel: XCUIElement {
        return app.staticTexts["Enter your school's domain or tap for help."] // label
    }

    //# MARK: - Default school domain strings

    static let defaultDomain = "mobileqa.instructure.com"
    static let defaultDomainShort = "mobileqa"

    //# MARK: - Assertion Helpers

    func assertCanvasLogo(file: String = #file, _ line: UInt = #line) {
        assertExists(canvasLogo, file, line)
    }

    func assertHelpMenuOptions(file: String = #file, _ line: UInt = #line) {
        assertExists(helpMenuTitle, file, line)
        assertExists(reportProblemButton, file, line)
        assertExists(requestFeatureButton, file, line)
        assertExists(findSchoolDomainButton, file, line)
        assertExists(cancelButton, file, line)
    }

    func assertDomainField(file: String = #file, _ line: UInt = #line) {
        assertExists(schoolDomainField, file, line)
        assertExists(schoolDomainButton, file, line)
    }

    func assertDomainList() {
        XCTAssert(app.tables.cells.count >= 3)
    }

    func assertCantFindSchool(file: String = #file, _ line: UInt = #line) {
        assertExists(cantFindSchoolLabel, file, line)
        assertExists(tapForHelpLabel, file, line)
    }

    //# MARK: - UI Action Helpers

    func openHelpMenu() {
        tap(helpMenuButton)
    }

    func closeHelpMenu() {
        tap(cancelButton)
    }

    func gotoHelpFindDomain() {
        openHelpMenu()
        tap(findSchoolDomainButton)
    }

    func gotoHelpReportProblem() {
        openHelpMenu()
        tap(reportProblemButton)
    }

    func gotoHelpRequestFeature() {
        openHelpMenu()
        tap(requestFeatureButton)
    }

    func enterSchool(domain: String) {
        typeText(schoolDomainField, domain)
    }

    func loadSchool(domain: String = defaultDomain) {
        enterSchool(domain)
        tap(schoolDomainButton)
    }

    func selectSchoolFromListByIndex(index: UInt = 0) {
        tap(app.tables.cells.elementBoundByIndex(index))
    }

    func selectCantFindSchool() {
        tap(cantFindSchoolLabel)
    }
}
