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

public var app: XCUIApplication { XCUIApplication() }

public extension XCUIElement {
    static let defaultTimeout: TimeInterval = 15
    static let defaultGracePeriod: UInt32 = 1
    var isVisible: Bool { self.exists }

    enum ElementCondition {
        case visible
        case vanish
        case value
        case label
        case enabled
        case selected
    }

    enum ElementAction {
        case swipeUp
        case swipeDown
        case swipeRight
        case swipeLeft
        case tap
        case showKeyboard
        case hideKeyboard
        case pullToRefresh
    }

    func hasValue(value: String) -> Bool {
        return self.value as? String == value
    }

    func hasLabel(label: String) -> Bool {
        return self.label == label
    }

    @discardableResult
    func hit() -> XCUIElement {
        waitUntil(condition: .visible)
        tap()
        return self
    }

    @discardableResult
    func waitUntil(condition: ElementCondition,
                   expected: String? = nil,
                   timeout: TimeInterval = defaultTimeout,
                   gracePeriod: UInt32 = defaultGracePeriod) -> XCUIElement {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            var result = false
            
            switch condition {
            case .vanish:
                result = !isVisible
            case .visible:
                result = isVisible
            case .value:
                result = hasValue(value: expected!)
            case .label:
                result = hasLabel(label: expected!)
            case .enabled:
                result = exists && isEnabled
            case .selected:
                result = exists && isSelected
            }
            if result { break } else { sleep(gracePeriod) }
        }
        return self
    }

    @discardableResult
    func actionUntilElementCondition(action: ElementAction = .tap,
                                     element: XCUIElement? = nil,
                                     condition: ElementCondition,
                                     expected: String? = nil,
                                     timeout: TimeInterval = defaultTimeout,
                                     gracePeriod: UInt32 = defaultGracePeriod) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            let actualElement = element ?? self
            var result = false

            switch condition {
            case .vanish:
                result = !(actualElement.isVisible && actualElement.isHittable)
            case .visible:
                result = actualElement.isVisible
            case .value:
                result = actualElement.hasValue(value: expected!)
            case .label:
                result = actualElement.hasLabel(label: expected!)
            case .enabled:
                result = actualElement.exists && actualElement.isEnabled
            case .selected:
                result = actualElement.exists && actualElement.isSelected
            }
            if result { return true } else {
                switch action {
                case .tap: tap()
                case .swipeUp: swipeUp()
                case .swipeDown: swipeDown()
                case .swipeLeft: swipeLeft()
                case .swipeRight: swipeRight()
                case .showKeyboard: CoreUITestCase.currentTestCase?.send(.showKeyboard, ignoreErrors: true)
                case .hideKeyboard: CoreUITestCase.currentTestCase?.send(.hideKeyboard, ignoreErrors: true)
                case .pullToRefresh: pullToRefresh()
                }

                sleep(gracePeriod)
            }
        }
        return false
    }

    @discardableResult
    func writeText(text: String) -> XCUIElement {
        hit()
        let keyboard = app.find(type: .keyboard)
        keyboard.actionUntilElementCondition(action: .showKeyboard, condition: .visible)
        waitUntil(condition: .visible)
        typeText(text)
        keyboard.actionUntilElementCondition(action: .hideKeyboard, condition: .vanish)
        return self
    }

    @discardableResult
    func pasteText(text: String, file: StaticString = #file, line: UInt = #line) -> XCUIElement {
        UIPasteboard.general.string = text
        let paste = app.find(label: "Paste", type: .menuItem)
        actionUntilElementCondition(action: .tap, element: paste, condition: .visible)
        paste.tap()
        return self
    }

    @discardableResult
    func cutText() -> XCUIElement {
        let selectAll = app.find(label: "Select All")
        actionUntilElementCondition(action: .tap, element: selectAll, condition: .visible)
        selectAll.tap()
        app.find(label: "Cut").hit()
        return self
    }

    func relativeCoordinate(x: CGFloat, y: CGFloat) -> XCUICoordinate {
        return coordinate(withNormalizedOffset: CGVector(dx: x, dy: y))
    }

    func pullToRefresh(x: CGFloat = 0.5) {
        relativeCoordinate(x: x, y: 0.2).press(forDuration: 0.05, thenDragTo: relativeCoordinate(x: x, y: 1.0))
    }

    // MARK: Find
    func find(label: String, type: ElementType = .any) -> XCUIElement {
        return descendants(matching: type).matching(label: label).firstMatch
    }

    func find(labelContaining needle: String, type: ElementType = .any) -> XCUIElement {
        return descendants(matching: type).matching(labelContaining: needle).firstMatch
    }

    func find(id: String, type: ElementType = .any) -> XCUIElement {
        return descendants(matching: type).matching(id: id).firstMatch
    }

    func find(idStartingWith prefix: String, type: ElementType = .any) -> XCUIElement {
        return descendants(matching: type).matching(idStartingWith: prefix).firstMatch
    }

    func find(value: String, type: ElementType = .any) -> XCUIElement {
        return descendants(matching: type).matching(value: value).firstMatch
    }

    func find(type: ElementType = .any) -> XCUIElement {
        return descendants(matching: type).firstMatch
    }

    func find(id: String, label: String, type: ElementType = .any) -> XCUIElement {
        return descendants(matching: type).matching(id: id).matching(label: label).firstMatch
    }

    func findAll(type: XCUIElement.ElementType, minimumCount: Int = 1, timeout: TimeInterval = defaultTimeout, gracePeriod: UInt32 = defaultGracePeriod) -> [XCUIElement] {
        let deadline = Date().addingTimeInterval(timeout)
        var result = descendants(matching: type).allElementsBoundByIndex
        while Date() < deadline {
            if result.count >= minimumCount { return result } else {
                sleep(gracePeriod)
                result = descendants(matching: type).allElementsBoundByIndex
            }
        }
        return result
    }

    func findAll(labelContaining: String, type: ElementType = .any) -> [XCUIElement] {
        descendants(matching: type).matching(labelContaining: labelContaining).allElementsBoundByIndex
    }

    // MARK: - Alerts

    func findAlertButton(label: String) -> XCUIElement {
        descendants(matching: .alert).descendants(matching: .button).matching(label: label).firstMatch
    }

    func findAlertStaticText(label: String) -> XCUIElement {
        descendants(matching: .alert).descendants(matching: .staticText).matching(label: label).firstMatch
    }
}
