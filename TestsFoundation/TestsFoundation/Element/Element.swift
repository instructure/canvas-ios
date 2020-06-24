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
    var queryWrapper: XCUIElementQueryWrapper { get }
    var rawElement: XCUIElement { get }
    func snapshot(file: StaticString, line: UInt) -> XCUIElementSnapshot?

    /// returns true if this element, or any of its children have keyboard focus
    func containsKeyboardFocusedElement(file: StaticString, line: UInt) -> Bool
}

public extension Element {
    func isOffscreen(_ timeout: TimeInterval = 10, file: StaticString = #file, line: UInt = #line) -> Bool {
        waitToExist(timeout, file: file, line: line)
        return !app.windows.element(boundBy: 0).frame.contains(frame(file: file, line: line))
    }

    func tapUntil(file: StaticString = #file, line: UInt = #line, message: String? = nil, test: () -> Bool) {
        tap(file: file, line: line)
        sleep(1)
        for _ in 0..<5 where exists(file: file, line: line) {
            if test() {
                return
            }
            tap(file: file, line: line)
            sleep(1)
        }
        waitUntil(file: file, line: line, predicate: test)
    }

    func toggleOn(file: StaticString = #file, line: UInt = #line) {
        tapUntil(file: file, line: line, message: "failed to toggle on") {
            value(file: file, line: line) == "1"
        }
    }

    func toggleOff(file: StaticString = #file, line: UInt = #line) {
        tapUntil(file: file, line: line, message: "failed to toggle off") {
            value(file: file, line: line) == "0"
        }
    }

    func exists(file: StaticString = #file, line: UInt = #line) -> Bool {
        snapshot(file: file, line: line) != nil
    }
    var exists: Bool { exists() }

    var elementType: XCUIElement.ElementType { return rawElement.elementType }
    var id: String { rawElement.identifier }
    var isEnabled: Bool { exists && rawElement.isEnabled }
    var isSelected: Bool { rawElement.isSelected }
    var isVisible: Bool { exists && rawElement.isHittable }
    var center: XCUICoordinate {
        rawElement.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
    }

    func relativeCoordinate(x: CGFloat, y: CGFloat) -> XCUICoordinate {
        rawElement.coordinate(withNormalizedOffset: CGVector(dx: x, dy: y))
    }

    func frame(file: StaticString = #file, line: UInt = #line) -> CGRect {
        waitToExist(30, file: file, line: line)
        return rawElement.frame
    }
    func label(file: StaticString = #file, line: UInt = #line) -> String {
        waitToExist(30, file: file, line: line)
        return rawElement.label
    }
    func value(file: StaticString = #file, line: UInt = #line) -> String? {
        waitToExist(30, file: file, line: line)
        return rawElement.value as? String
    }

    @discardableResult
    func pick(column: Int, value: String, file: StaticString = #file, line: UInt = #line) -> Element {
        waitToExist(file: file, line: line)
        rawElement.pickerWheels.allElementsBoundByIndex[column].adjust(toPickerWheelValue: value)
        return self
    }

    @discardableResult
    func tap(file: StaticString = #file, line: UInt = #line) -> Element {
        waitToExist(file: file, line: line)
        rawElement.tap()
        return self
    }

    @discardableResult
    func tapAt(_ point: CGPoint, file: StaticString = #file, line: UInt = #line) -> Element {
        waitToExist(file: file, line: line)
        rawElement.coordinate(withNormalizedOffset: .zero)
            .withOffset(CGVector(dx: point.x, dy: point.y))
            .tap()
        return self
    }

    @discardableResult
    func typeText(_ text: String, file: StaticString = #file, line: UInt = #line) -> Element {
        tap(file: file, line: line)
        CoreUITestCase.currentTestCase?.send(.showKeyboard, ignoreErrors: true)
        var taps = 1
        while !containsKeyboardFocusedElement(file: file, line: line), taps < 5 {
            tap(file: file, line: line)
            CoreUITestCase.currentTestCase?.send(.showKeyboard, ignoreErrors: true)
            taps += 1
            sleep(1)
        }
        rawElement.typeText(text)
        return self
    }

    @discardableResult
    func swipeLeft(file: StaticString = #file, line: UInt = #line) -> Element {
        waitToExist(file: file, line: line)
        rawElement.swipeLeft()
        return self
    }

    @discardableResult
    func swipeRight(file: StaticString = #file, line: UInt = #line) -> Element {
        waitToExist(file: file, line: line)
        rawElement.swipeRight()
        return self
    }

    @discardableResult
    func swipeDown(file: StaticString = #file, line: UInt = #line) -> Element {
        waitToExist(file: file, line: line)
        rawElement.swipeDown()
        return self
    }

    @discardableResult
    func swipeUp(file: StaticString = #file, line: UInt = #line) -> Element {
        waitToExist(file: file, line: line)
        rawElement.swipeUp()
        return self
    }

    @discardableResult
    func waitToExist(_ timeout: TimeInterval = 30, file: StaticString = #file, line: UInt = #line) -> Element {
        waitUntil(timeout, file: file, line: line, failureMessage: "Element \(id) still doesn't exists") {
            exists(file: file, line: line)
        }
        return self
    }

    @discardableResult
    func waitToVanish(_ timeout: TimeInterval = 30, file: StaticString = #file, line: UInt = #line) -> Element {
        waitUntil(timeout, file: file, line: line, failureMessage: "Element \(id) still exists") {
            !exists(file: file, line: line)
        }
        return self
    }

    func snapshot(file: StaticString = #file, line: UInt = #line) -> XCUIElementSnapshot? {
        queryWrapper.snapshot(file: file, line: line)
    }

    var rawElement: XCUIElement {
        queryWrapper.rawElement
    }

    var allElements: [Element] {
        queryWrapper.allElements
    }

    /// returns true if this element, or any of its children have keyboard focus
    func containsKeyboardFocusedElement(file: StaticString = #file, line: UInt = #line) -> Bool {
        queryWrapper.containsKeyboardFocusedElement(file: file, line: line)
    }

    func orderedLabels(file: StaticString = #file, line: UInt = #line) -> [String]? {
        guard let elements = snapshot(file: file, line: line)?.dictionaryRepresentation else {
            return nil
        }

        var labels: [String] = []
        func traverse(_ element: [XCUIElement.AttributeName: Any]) {
            if let label = element[.label] as? String, !label.isEmpty {
                labels.append(label)
            } else if let children = element[.children] as? [[XCUIElement.AttributeName: Any]] {
                children.forEach(traverse)
            }
        }
        traverse(elements)
        return labels
    }

    func containsLabelSequence(_ subsequence: [String], file: StaticString = #file, line: UInt = #line) -> Bool {
        guard let labels = orderedLabels(file: file, line: line) else {
            return false
        }
        for i in labels.indices {
            if labels.dropFirst(i).starts(with: subsequence) {
                return true
            }
        }
        return false
    }

    subscript(_ index: Int) -> Element {
        XCUIElementQueryWrapper(queryWrapper.query, index: index)
    }
}

public func waitUntil(
    _ timeout: TimeInterval = 30,
    file: StaticString = #file,
    line: UInt = #line,
    failureMessage: @autoclosure () -> String = "waitUntil timed out",
    predicate: () -> Bool
) {
    let deadline = Date().addingTimeInterval(timeout)
    while !predicate() {
        XCTAssertTrue(Date() < deadline, failureMessage(), file: (file), line: line)
        usleep(100000)
    }
}

public struct XCUIElementQueryWrapper: Element {
    public let query: XCUIElementQuery
    public let index: Int

    public var queryWrapper: XCUIElementQueryWrapper { self }

    // A negative index counts backwards from the end, e.g. -1 is the last matching element
    public init(_ query: XCUIElementQuery, index: Int = 0) {
        self.query = query
        self.index = index
    }

    public func snapshot(file: StaticString = #file, line: UInt = #line) -> XCUIElementSnapshot? {
        var snapshot: XCUIElementSnapshot?
        let timeout = 30
        waitUntil(30, file: file, line: line, failureMessage: "failed to get snapshot within \(timeout) seconds") {
            do {
                snapshot = try query.allMatchingSnapshots().first as? XCUIElementSnapshot
                return true
            } catch {
                return false
            }
        }
        return snapshot
    }

    public var rawElement: XCUIElement {
        let rawIndex: Int
        if index < 0 {
            rawIndex = query.count + index
        } else {
            rawIndex = index
        }
        return query.element(boundBy: rawIndex)
    }

    public var allElements: [Element] {
        (0..<query.count).map { self[$0] }
    }

    /// returns true if this element, or any of its children have keyboard focus
    public func containsKeyboardFocusedElement(file: StaticString = #file, line: UInt = #line) -> Bool {
        waitToExist(file: file, line: line)
        // For some reason, if we don't ask for a specific element type, then snapshots get confused...
        let q2 = query.matching(NSPredicate(format: "%K == %i", #keyPath(XCUIElement.elementType), elementType.rawValue))
        guard let snapshot = XCUIElementQueryWrapper(q2).snapshot(file: file, line: line) else {
            // element doesn't exist
            return false
        }
        var children = [snapshot]
        while let element = children.popLast() {
            children.append(contentsOf: element.children)
            // Unfortunately, apple doesn't reliably expose focus
            if "\(element)".contains("Keyboard Focused") {
                return true
            }
        }
        return false
    }
}
