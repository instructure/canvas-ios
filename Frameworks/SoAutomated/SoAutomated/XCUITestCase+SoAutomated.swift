import XCTest
import Foundation

@available(iOS 9.0, *)
extension XCTestCase {
    // Make app available for use in page objects
    public var app: XCUIApplication {
        return XCUIApplication()
    }

    // http://stackoverflow.com/a/26567571
    class var waitTimeout: Double {
        return Static.waitTimeout
    }

    var waitTimeout: Double {
        return Static.waitTimeout
    }

    struct Static {
        static var waitTimeout: Double = 5
    }

    /*!
    * @discussion
    * A convenience method that waits for an element to exist then
    * returns the element.
    * Records a failure if the timeout elapses and the element doesn't exist.
    *
    * Based on: https://github.com/joemasilotti/UI-Testing-Cheat-Sheet/blob/a1a1f139c7de10d19012de7959da57862a4d0137/UITests/UITests.swift#L153
    *
    * @param element
    * The element to wait for
    *
    * @param timeout
    * The amount of time in seconds to wait for
    *
    * @return
    * Returns the element.
    */
    public func wait(element: XCUIElement, _ timeout: Double = waitTimeout, _ file: String = #file, _ line: UInt = #line) -> XCUIElement {
        let exists = NSPredicate(format: "exists == true")
        expectationForPredicate(exists, evaluatedWithObject: element, handler: nil)

        waitForExpectationsWithTimeout(timeout) { error in
            if error != nil {
                let description = "\(element) not found after waiting \(timeout) seconds."
                self.recordFailureWithDescription(description, inFile: file, atLine: line, expected: true)
            }
        }

        return element
    }

    public func typeText(textField: XCUIElement, _ text: String) -> XCUIElement {
        let textField = wait(textField)

        // Work around:
        // UI Testing Failure - Neither element nor any descendant has keyboard focus.
        // Use private API hasKeyboardFocus
        // https://forums.developer.apple.com/thread/5910

        var tap_count = 0

        repeat {
            textField.tap()
        } while (!textField.hasKeyboardFocus && ++tap_count < 10) // Give up if we don't have focus after 10 taps

        // Must have keyboard focus on the textField before typing.
        try! FBElementCommands.typeText(text)

        return textField
    }

    public func tap(object: XCUIElement) -> XCUIElement {
        assertHittable(object).tap()
        return object
    }

    public func assertExists(element: XCUIElement, _ file: String = #file, _ line: UInt = #line) {
        wait(element, waitTimeout, file, line)
    }

    public func assertEnabled(element: XCUIElement, _ file: String = #file, _ line: UInt = #line) {
        if wait(element, waitTimeout, file, line).enabled != true {
            let description = "Expected \(element) to be enabled."
            self.recordFailureWithDescription(description, inFile: file, atLine: line, expected: true)
        }
    }

    public func assertDisabled(element: XCUIElement, _ file: String = #file, _ line: UInt = #line) {
        if wait(element, waitTimeout, file, line).enabled != false {
            let description = "Expected \(element) to be disabled."
            self.recordFailureWithDescription(description, inFile: file, atLine: line, expected: false)
        }
    }

    public func assertCollectionCount(collection: XCUIElementQuery, expectedCount: Int, _ file: String = #file, _ line: UInt = #line) {
        let count = NSPredicate(format: "count == \(expectedCount)")
        expectationForPredicate(count, evaluatedWithObject: collection, handler: nil)

        waitForExpectationsWithTimeout(waitTimeout) { error in
            if error != nil {
                let description = "\(collection) expected to have \(expectedCount) elements."
                self.recordFailureWithDescription(description, inFile: file, atLine: line, expected: true)
            }
        }
    }

    public func assertHittable(var element: XCUIElement, _ timeout: Double = waitTimeout, _ file: String = #file, _ line: UInt = #line) -> XCUIElement {
        // first wait until element exists
        element = wait(element)

        // then make sure it is hittable
        let visible = NSPredicate(format: "hittable == true")
        expectationForPredicate(visible, evaluatedWithObject: element, handler: nil)

        waitForExpectationsWithTimeout(timeout) { error in
            if (error != nil) {
                let description = "\(element) not hittable after waiting \(timeout) seconds."
                self.recordFailureWithDescription(description, inFile: file, atLine: line, expected: true)
            }
        }

        return element
    }
}
