//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as
// published by the Free Software Foundation, either version 3 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//

import Foundation
import XCTest

public protocol Element {
    var elementType: XCUIElement.ElementType { get }
    var rawElement: XCUIElement { get }
    var exists: Bool { get }
    var id: String { get }
    var isEnabled: Bool { get }
    var isSelected: Bool { get }
    var isVisible: Bool { get }
    func frame(file: StaticString, line: UInt) -> CGRect
    func label(file: StaticString, line: UInt) -> String
    func value(file: StaticString, line: UInt) -> String?

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
    func frame(file: StaticString = #file, line: UInt = #line) -> CGRect {
        return frame(file: file, line: line)
    }
    func label(file: StaticString = #file, line: UInt = #line) -> String {
        return label(file: file, line: line)
    }
    func value(file: StaticString = #file, line: UInt = #line) -> String? {
        return value(file: file, line: line)
    }

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

public extension Element {
    @discardableResult
    func tapUntil(file: StaticString = #file, line: UInt = #line, test: () -> Bool) -> Element {
        var taps = 0
        repeat {
            tap(file: file, line: line)
            taps += 1
            sleep(1)
        } while taps < 5 && test() == false && exists
        return self
    }
}

public struct XCUIElementQueryWrapper: Element {
    public let query: XCUIElementQuery
    public let index: Int

    // A negative index counts backwards from the end, e.g. -1 is the last matching element
    public init(_ query: XCUIElementQuery, index: Int = 0) {
        self.query = query
        self.index = index
    }

    public var exists: Bool {
        let timeout: TimeInterval = 30

        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            do {
                return try query.allMatchingSnapshots().count > 0
            } catch {
                usleep(100000)
            }
        }
        XCTFail("Failed to get snapshot within \(timeout) seconds")
        return false
    }

    public var elementType: XCUIElement.ElementType { return rawElement.elementType }
    public var rawElement: XCUIElement {
        let rawIndex: Int
        if index < 0 {
            rawIndex = query.count + index
        } else {
            rawIndex = index
        }
        return query.element(boundBy: rawIndex)
    }
    public var id: String { rawElement.identifier }
    public var isEnabled: Bool { exists && rawElement.isEnabled }
    public var isSelected: Bool { rawElement.isSelected }
    public var isVisible: Bool { exists && rawElement.isHittable }

    public func frame(file: StaticString = #file, line: UInt = #line) -> CGRect {
        waitToExist(30, file: file, line: line)
        return rawElement.frame
    }
    public func label(file: StaticString = #file, line: UInt = #line) -> String {
        waitToExist(30, file: file, line: line)
        return rawElement.label
    }
    public func value(file: StaticString = #file, line: UInt = #line) -> String? {
        waitToExist(30, file: file, line: line)
        return rawElement.value as? String
    }

    @discardableResult
    public func pick(column: Int, value: String, file: StaticString, line: UInt) -> Element {
        waitToExist(file: file, line: line)
        rawElement.pickerWheels.allElementsBoundByIndex[column].adjust(toPickerWheelValue: value)
        return self
    }

    @discardableResult
    public func tap(file: StaticString, line: UInt) -> Element {
        waitToExist(file: file, line: line)
        rawElement.tap()
        return self
    }

    @discardableResult
    public func tapAt(_ point: CGPoint, file: StaticString, line: UInt) -> Element {
        waitToExist(file: file, line: line)
        rawElement.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: point.x, dy: point.y))
            .tap()
        return self
    }

    @discardableResult
    public func typeText(_ text: String, file: StaticString, line: UInt) -> Element {
        rawElement.tap()
        rawElement.typeText(text)
        return self
    }

    @discardableResult
    public func swipeDown(file: StaticString, line: UInt) -> Element {
        waitToExist(file: file, line: line)
        rawElement.swipeDown()
        return self
    }

    @discardableResult
    public func swipeUp(file: StaticString, line: UInt) -> Element {
        waitToExist(file: file, line: line)
        rawElement.swipeUp()
        return self
    }

    @discardableResult
    public func waitToExist(_ timeout: TimeInterval, file: StaticString, line: UInt) -> Element {
        let deadline = Date().addingTimeInterval(timeout)
        while !exists {
            XCTAssertTrue(Date() < deadline, "Element \(id) still doesn't exists", file: file, line: line)
            usleep(100000)
        }
        return self
    }

    @discardableResult
    public func waitToVanish(_ timeout: TimeInterval, file: StaticString, line: UInt) -> Element {
        let deadline = Date().addingTimeInterval(timeout)
        while exists {
            XCTAssertTrue(Date() < deadline, "Element \(id) still exists", file: file, line: line)
            usleep(100000)
        }
        return self
    }
}
