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
    // MARK: Enums
    enum ElementCondition {
        case visible
        case vanish
        case value(expected: String)
        case label(expected: String)
        case enabled
        case selected
        case unselected
        case hittable
        case labelContaining(expected: String)
        case labelHasPrefix(expected: String)
        case idContains(expected: String)
    }

    enum ElementAction {
        public enum Target {
            case onApp
            case onElement
        }

        case swipeUp(_ target: Target = .onApp)
        case swipeDown(_ target: Target = .onApp)
        case swipeRight(_ target: Target = .onApp)
        case swipeLeft(_ target: Target = .onApp)
        case tap
        case showKeyboard
        case hideKeyboard
        case pullToRefresh
        case forceTap
        case longTap
    }

    // MARK: Static vars
    static let defaultTimeout: TimeInterval = 15
    static var defaultGracePeriod: TimeInterval = 1

    // MARK: Private vars
    var isVisible: Bool { exists }
    var isVanished: Bool { !(exists && isHittable) }

    // MARK: Functions
    func tacticalSleep(_ seconds: TimeInterval = 0.5) { usleep(UInt32(seconds*1000000)) }

    func idContains(expected: String) -> Bool { identifier.contains(expected) }

    func hasValue(value expectedValue: String, strict: Bool = true) -> Bool {
        let elementValue = value as? String ?? ""
        return strict ? elementValue == expectedValue : elementValue.contains(expectedValue)
    }

    func hasLabel(label expectedLabel: String, strict: Bool = true) -> Bool {
        return strict ? label == expectedLabel : label.contains(expectedLabel)
    }

    @discardableResult
    func hit() -> XCUIElement {
        waitUntil(.visible).waitUntil(.hittable, timeout: 5)
        if !isHittable { actionUntilElementCondition(action: .swipeUp(), condition: .hittable, timeout: 5) }
        tap()
        tacticalSleep(1)
        return self
    }

    /**
     * Waits until the given condition is true.
     *
     * - parameters
     *     - condition: The condition that the element should fulfill.
     *     - timeout: Optional. Time interval as timeout for the function. By default it's defaultTimeout.
     *     - gracePeriod: Optional. Time interval to wait between each iteration.
     * - returns: self, so calls can be chained.
     */
    @discardableResult
    func waitUntil(_ condition: ElementCondition,
                   timeout: TimeInterval = defaultTimeout,
                   gracePeriod: TimeInterval = defaultGracePeriod) -> XCUIElement {
        tacticalSleep()
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            var result = false

            switch condition {
            case .vanish:
                result = isVanished
            case .visible:
                result = isVisible
            case .value(let expected):
                result = hasValue(value: expected)
            case .label(let expected):
                result = hasLabel(label: expected)
            case .enabled:
                result = exists && isEnabled
            case .selected:
                result = exists && isSelected
            case .unselected:
                result = !isSelected
            case .hittable:
                result = isVisible && isHittable
            case .labelContaining(let expected):
                result = label.contains(expected)
            case .labelHasPrefix(let expected):
                result = label.hasPrefix(expected)
            case .idContains(let expected):
                result = idContains(expected: expected)
            }
            if result { break } else { tacticalSleep(gracePeriod) }
        }
        return self
    }

    /**
     * Does an action (tap, swipe, etc.) to the element until the given condition is true.
     *
     * - parameters
     *     - action:The action to do to the element.
     *     - element: Optional. The element to check after the action happened. By default it's self.
     *     - condition: The condition that the element should fulfill.
     *     - timeout: Optional. Time interval as timeout for the function. By default it's defaultTimeout.
     *     - gracePeriod: Optional. Time interval to wait between each iteration.
     * - returns: true or false, depending on if the condition has been fulfilled.
     */
    @discardableResult
    func actionUntilElementCondition(action: ElementAction,
                                     element: XCUIElement? = nil,
                                     condition: ElementCondition,
                                     timeout: TimeInterval = defaultTimeout,
                                     gracePeriod: TimeInterval = defaultGracePeriod) -> Bool {
        tacticalSleep()
        let deadline = Date().addingTimeInterval(timeout)
        let actualElement = element ?? self

        while Date() < deadline {
            var result = false

            switch condition {
            case .vanish:
                result = actualElement.isVanished
            case .visible:
                result = actualElement.isVisible
            case .value(let expected):
                result = actualElement.hasValue(value: expected)
            case .label(let expected):
                result = actualElement.hasLabel(label: expected)
            case .enabled:
                result = actualElement.exists && actualElement.isEnabled
            case .selected:
                result = actualElement.exists && actualElement.isSelected
            case .unselected:
                result = !actualElement.isSelected
            case .hittable:
                result = actualElement.isVisible && actualElement.isHittable
            case .labelContaining(let expected):
                result = label.contains(expected)
            case .labelHasPrefix(let expected):
                result = label.hasPrefix(expected)
            case .idContains(let expected):
                result = idContains(expected: expected)
            }

            if result { return true }

            switch action {
            case .tap: hit()
            case .showKeyboard: CoreUITestCase.currentTestCase?.send(.showKeyboard, ignoreErrors: true)
            case .hideKeyboard: CoreUITestCase.currentTestCase?.send(.hideKeyboard, ignoreErrors: true)
            case .pullToRefresh: app.pullToRefresh()
            case .swipeUp(let target):
                switch target {
                case .onApp: app.swipeUp()
                case .onElement: swipeUp()
                }
            case .swipeDown(let target):
                switch target {
                case .onApp: app.swipeDown()
                case .onElement: swipeDown()
                }
            case .swipeRight(let target):
                switch target {
                case .onApp: app.swipeRight()
                case .onElement: swipeRight()
                }
            case .swipeLeft(let target):
                switch target {
                case .onApp: app.swipeLeft()
                case .onElement: swipeLeft()
                }
            case .forceTap: forceTap()
            case .longTap: longTap()
            }

            tacticalSleep(gracePeriod)
        }
        return false
    }

    @discardableResult
    func writeText(text: String) -> XCUIElement {
        hit()
        let keyboard = app.find(type: .keyboard)
        keyboard.actionUntilElementCondition(action: .showKeyboard, condition: .visible)
        waitUntil(.visible)
        typeText(text)
        keyboard.actionUntilElementCondition(action: .hideKeyboard, condition: .vanish)
        return self
    }

    @discardableResult
    func pasteText(text: String) -> XCUIElement {
        UIPasteboard.general.string = text
        let paste = app.find(label: "Paste", type: .menuItem)
        actionUntilElementCondition(action: .tap, element: paste, condition: .visible)
        paste.hit()
        return self
    }

    @discardableResult
    func cutText() -> XCUIElement {
        let selectAll = app.find(label: "Select All")
        actionUntilElementCondition(action: .tap, element: selectAll, condition: .visible)
        selectAll.hit()
        app.find(label: "Cut").hit()
        return self
    }

    func relativeCoordinate(x: CGFloat, y: CGFloat) -> XCUICoordinate {
        return coordinate(withNormalizedOffset: CGVector(dx: x, dy: y))
    }

    func pullToRefresh(x: CGFloat = 0.5) {
        relativeCoordinate(x: x, y: 0.2).press(forDuration: 0.05, thenDragTo: relativeCoordinate(x: x, y: 1.0))
    }

    func tapAt(_ point: CGPoint) {
        waitUntil(.hittable)
        coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: point.x, dy: point.y)).tap()
    }

    func forceTap() {
        waitUntil(.visible)
        let coordinatesToTap = CGPoint(x: frame.midX, y: frame.midY)
        app.tapAt(coordinatesToTap)
    }

    func longTap() {
        press(forDuration: 2)
    }

    // MARK: Find functions
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

    func find(type: ElementType) -> XCUIElement {
        return descendants(matching: type).firstMatch
    }

    func find(id: String, label: String, type: ElementType = .any) -> XCUIElement {
        return descendants(matching: type).matching(id: id).matching(label: label).firstMatch
    }

    func findAll(type: XCUIElement.ElementType, minimumCount: Int = 1, timeout: TimeInterval = defaultTimeout, gracePeriod: TimeInterval = defaultGracePeriod) -> [XCUIElement] {
        let deadline = Date().addingTimeInterval(timeout)
        var result = descendants(matching: type).allElementsBoundByIndex
        while Date() < deadline && result.count < minimumCount {
            tacticalSleep(gracePeriod)
            result = descendants(matching: type).allElementsBoundByIndex
        }
        return result
    }

    func findAll(labelContaining: String, type: ElementType = .any) -> [XCUIElement] {
        return descendants(matching: type).matching(labelContaining: labelContaining).allElementsBoundByIndex
    }

    func findAll(idStartingWith: String, type: ElementType = .any) -> [XCUIElement] {
        return descendants(matching: type).matching(idStartingWith: idStartingWith).allElementsBoundByIndex
    }

    // MARK: Find alert functions

    func findAlertButton(label: String) -> XCUIElement {
        return descendants(matching: .alert).descendants(matching: .button).matching(label: label).firstMatch
    }

    func findAlertStaticText(label: String) -> XCUIElement {
        return descendants(matching: .alert).descendants(matching: .staticText).matching(label: label).firstMatch
    }
}
