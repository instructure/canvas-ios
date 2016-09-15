import Foundation
import XCTest

@available(iOS 9.0, *)
public class TestPage {

    public let tc: XCTestCase
    public let app: XCUIApplication
    public let typeText: (XCUIElement, String) -> XCUIElement
    public let tap: (XCUIElement) -> XCUIElement
    public let assertExists: (XCUIElement, String, UInt) -> ()
    public let assertEnabled: (XCUIElement, String, UInt) -> ()
    public let assertDisabled: (XCUIElement, String, UInt) -> ()
    public let assertCollectionCount: (XCUIElementQuery, Int, String, UInt) -> ()

    public init (_ testCase: XCTestCase) {
        self.tc = testCase
        self.app = testCase.app
        self.typeText = testCase.typeText
        self.tap = testCase.tap
        self.assertExists = testCase.assertExists
        self.assertEnabled = testCase.assertEnabled
        self.assertDisabled = testCase.assertDisabled
        self.assertCollectionCount = testCase.assertCollectionCount
    }
}
