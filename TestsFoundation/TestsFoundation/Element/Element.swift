//
// Copyright (C) 2019-present Instructure, Inc.
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

import Foundation
import XCTest

public protocol Element {
    var elementType: XCUIElement.ElementType { get }
    var exists: Bool { get }
    var frame: CGRect { get }
    var id: String { get }
    var isEnabled: Bool { get }
    var isSelected: Bool { get }
    var isVisible: Bool { get }
    var label: String { get }
    var value: String { get }

    @discardableResult
    func pick(column: Int, value: String, file: StaticString, line: UInt) -> Element

    @discardableResult
    func swipeDown(file: StaticString, line: UInt) -> Element

    @discardableResult
    func swipeUp(file: StaticString, line: UInt) -> Element

    @discardableResult
    func tap(file: StaticString, line: UInt) -> Element

    @discardableResult
    func tapAt(_ point: CGPoint, file: StaticString, line: UInt) -> Element

    @discardableResult
    func typeText(_ text: String, file: StaticString, line: UInt) -> Element

    @discardableResult
    func waitToExist(_ timeout: TimeInterval, file: StaticString, line: UInt) -> Element

    @discardableResult
    func waitToVanish(_ timeout: TimeInterval, file: StaticString, line: UInt) -> Element
}

public extension Element {
    @discardableResult
    func pick(column: Int, value: String, file: StaticString = #file, line: UInt = #line) -> Element {
        return pick(column: column, value: value, file: file, line: line)
    }

    @discardableResult
    func swipeDown(file: StaticString = #file, line: UInt = #line) -> Element {
        return swipeDown(file: file, line: line)
    }

    @discardableResult
    func swipeUp(file: StaticString = #file, line: UInt = #line) -> Element {
        return swipeUp(file: file, line: line)
    }

    @discardableResult
    func tap(file: StaticString = #file, line: UInt = #line) -> Element {
        return tap(file: file, line: line)
    }

    @discardableResult
    func tapAt(_ point: CGPoint, file: StaticString = #file, line: UInt = #line) -> Element {
        return tapAt(point, file: file, line: line)
    }

    @discardableResult
    func typeText(_ text: String, file: StaticString = #file, line: UInt = #line) -> Element {
        return typeText(text, file: file, line: line)
    }

    @discardableResult
    func waitToExist(_ timeout: TimeInterval = 30, file: StaticString = #file, line: UInt = #line) -> Element {
        return waitToExist(timeout, file: file, line: line)
    }

    @discardableResult
    func waitToVanish(_ timeout: TimeInterval = 10, file: StaticString = #file, line: UInt = #line) -> Element {
        return waitToVanish(timeout, file: file, line: line)
    }
}

public struct XCUIElementWrapper: Element {
    var element: XCUIElement {
        return finder()
    }
    private let finder: () -> XCUIElement

    public init(_ finder: @autoclosure @escaping () -> XCUIElement) {
        self.finder = finder
    }

    public var elementType: XCUIElement.ElementType {
        return element.elementType
    }
    public var exists: Bool {
        return element.exists
    }
    public var frame: CGRect {
        guard exists else { return .zero }
        return element.frame
    }
    public var id: String {
        guard exists else { return "" }
        return element.identifier
    }
    public var isEnabled: Bool {
        guard exists else { return false }
        return element.isEnabled
    }
    public var isSelected: Bool {
        guard exists else { return false }
        return element.isSelected
    }
    public var isVisible: Bool {
        guard exists else { return false }
        return element.isHittable
    }
    public var label: String {
        guard exists else { return "" }
        return element.label
    }
    public var value: String {
        guard exists else { return "" }
        return element.value as? String ?? ""
    }

    @discardableResult
    public func pick(column: Int, value: String, file: StaticString, line: UInt) -> Element {
        waitToExist(file: file, line: line)
        element.pickerWheels.allElementsBoundByIndex[column].adjust(toPickerWheelValue: value)
        return self
    }

    @discardableResult
    public func tap(file: StaticString, line: UInt) -> Element {
        waitToExist(file: file, line: line)
        element.tap()
        return self
    }

    @discardableResult
    public func tapAt(_ point: CGPoint, file: StaticString, line: UInt) -> Element {
        waitToExist(file: file, line: line)
        element.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: point.x, dy: point.y))
            .tap()
        return self
    }

    @discardableResult
    public func typeText(_ text: String, file: StaticString, line: UInt) -> Element {
        waitToExist(file: file, line: line)
        element.tap()
        element.typeText(text)
        return self
    }

    @discardableResult
    public func swipeDown(file: StaticString, line: UInt) -> Element {
        waitToExist(file: file, line: line)
        element.swipeDown()
        return self
    }

    @discardableResult
    public func swipeUp(file: StaticString, line: UInt) -> Element {
        waitToExist(file: file, line: line)
        element.swipeUp()
        return self
    }

    @discardableResult
    public func waitToExist(_ timeout: TimeInterval, file: StaticString, line: UInt) -> Element {
        if !element.exists {
            XCTAssertTrue(element.waitForExistence(timeout: timeout), "Element \(id) not found", file: file, line: line)
        }
        return self
    }

    @discardableResult
    public func waitToVanish(_ timeout: TimeInterval, file: StaticString, line: UInt) -> Element {
        let deadline = Date().addingTimeInterval(timeout)
        while element.exists, Date() < deadline {
            sleep(1)
        }
        XCTAssertFalse(element.exists, "Element \(id) still exists", file: file, line: line)
        return self
    }
}
