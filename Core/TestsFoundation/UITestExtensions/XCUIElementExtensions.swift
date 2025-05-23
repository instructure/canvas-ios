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
        case value(expected: String, strict: Bool = true)
        case label(expected: String, strict: Bool = true)
        case enabled
        case disabled
        case selected
        case unselected
        case hittable
        case labelContaining(expected: String)
        case labelHasPrefix(expected: String)
        case labelHasSuffix(expected: String)
        case idContains(expected: String)
    }

    enum ElementAction {
        public enum Target {
            case onApp
            case onElement
            case customApp(_ customApp: XCUIApplication)
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

    // MARK: Constants

    static let defaultTimeout: TimeInterval = 20
    static let defaultGracePeriod: TimeInterval = 1

    // MARK: Properties

    var isVisible: Bool { exists }
    var isDisabled: Bool { !isEnabled }
    var isUnselected: Bool { !isSelected }
    var isVanished: Bool { !(exists && isHittable) }

    var stringValue: String? {
        value as? String
    }

    // MARK: Functions
    func tacticalSleep(_ seconds: TimeInterval = 0.5) { usleep(UInt32(seconds*1000000)) }

    private func hasValue(value expectedValue: String, strict: Bool = true) -> Bool {
        let elementValue = value as? String ?? ""
        return strict ? elementValue == expectedValue : elementValue.contains(expectedValue)
    }

    private func hasLabel(label expectedLabel: String, strict: Bool = true) -> Bool {
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

    private func checkCondition(_ condition: ElementCondition) -> Bool {
        switch condition {
        case .vanish: isVanished
        case .visible: isVisible
        case .value(let expected, let strict): hasValue(value: expected, strict: strict)
        case .label(let expected, let strict): hasLabel(label: expected, strict: strict)
        case .enabled: exists && isEnabled
        case .disabled: isDisabled
        case .selected: exists && isSelected
        case .unselected: !isSelected
        case .hittable: isVisible && isHittable
        case .labelContaining(let expected): label.contains(expected)
        case .labelHasPrefix(let expected): label.hasPrefix(expected)
        case .labelHasSuffix(let expected): label.hasSuffix(expected)
        case .idContains(let expected): identifier.contains(expected)
        }
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
    func waitUntil(
        _ condition: ElementCondition,
        timeout: TimeInterval = defaultTimeout,
        gracePeriod: TimeInterval = defaultGracePeriod
    ) -> XCUIElement {
        tacticalSleep()
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if checkCondition(condition) {
                return self
            }

            tacticalSleep(gracePeriod)
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
    func actionUntilElementCondition(
        action: ElementAction,
        element: XCUIElement? = nil,
        condition: ElementCondition,
        timeout: TimeInterval = defaultTimeout,
        gracePeriod: TimeInterval = defaultGracePeriod
    ) -> Bool {
        tacticalSleep()
        let deadline = Date().addingTimeInterval(timeout)
        let actualElement = element ?? self

        while Date() < deadline {
            if actualElement.checkCondition(condition) {
                return true
            }

            switch action {
            case .tap: hit()
            case .showKeyboard: CoreUITestCase.currentTestCase?.send(.showKeyboard, ignoreErrors: true)
            case .hideKeyboard: CoreUITestCase.currentTestCase?.send(.hideKeyboard, ignoreErrors: true)
            case .pullToRefresh: app.pullToRefresh()
            case .swipeUp(let target):
                switch target {
                case .onApp: app.swipeUp()
                case .onElement: swipeUp()
                case .customApp(let customApp):
                    customApp.swipeUp()
                }
            case .swipeDown(let target):
                switch target {
                case .onApp: app.swipeDown()
                case .onElement: swipeDown()
                case .customApp(let customApp):
                    customApp.swipeDown()
                }
            case .swipeRight(let target):
                switch target {
                case .onApp: app.swipeRight()
                case .onElement: swipeRight()
                case .customApp(let customApp):
                    customApp.swipeRight()
                }
            case .swipeLeft(let target):
                switch target {
                case .onApp: app.swipeLeft()
                case .onElement: swipeLeft()
                case .customApp(let customApp):
                    customApp.swipeLeft()
                }
            case .forceTap: forceTap()
            case .longTap: longTap()
            }

            tacticalSleep(gracePeriod)
        }
        return false
    }

    @discardableResult
    func writeText(text: String, hitGo: Bool = false, hitEnter: Bool = false, customApp: XCUIApplication? = nil) -> XCUIElement {
        let appInUse = customApp ?? app
        hit()
        let keyboard = appInUse.find(type: .keyboard)
        keyboard.actionUntilElementCondition(action: .showKeyboard, condition: .visible)
        waitUntil(.visible)
        typeText(text)
        if hitGo {
            keyboard.find(id: "Go", type: .button).hit()
        } else if hitEnter {
            typeText("\n")
        } else {
            keyboard.actionUntilElementCondition(action: .hideKeyboard, condition: .vanish)
        }
        return self
    }

    @discardableResult
    func pasteText(text: String, customApp: XCUIApplication? = nil, pasteAndGo: Bool = false) -> XCUIElement {
        let appInUse = customApp ?? app
        UIPasteboard.general.string = text
        let paste = pasteAndGo ? appInUse.find(label: "Paste and Go", type: .menuItem) : appInUse.find(label: "Paste", type: .menuItem)
        actionUntilElementCondition(action: .tap, element: paste, condition: .visible)
        paste.hit()
        return self
    }

    @discardableResult
    func cutText(tapSelectAll: Bool = true, customApp: XCUIApplication? = nil) -> XCUIElement {
        let appInUse = customApp ?? app
        if tapSelectAll {
            let selectAll = appInUse.find(label: "Select All")
            actionUntilElementCondition(action: .tap, element: selectAll, condition: .visible)
            selectAll.hit()
        }
        let cutButton = appInUse.find(label: "Cut")
        let cutVisible = actionUntilElementCondition(action: .tap, element: cutButton, condition: .visible, timeout: 5)
        if cutVisible { cutButton.hit() }
        return self
    }

    func pullToRefresh(x: CGFloat = 0.5, y: CGFloat = 0.2) {
        XCTContext.runActivity(named: "Pull To Refresh on \(label)") { _ in
            let gestureStart = coordinate(withNormalizedOffset: CGVector(dx: x, dy: y))
            let dy = app.frame.height - gestureStart.screenPoint.y
            let gestureEnd = gestureStart.withOffset(CGVector(dx: 0, dy: dy))
            gestureStart.press(forDuration: 0.05, thenDragTo: gestureEnd)
        }
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

    func tapAndHoldAndDragToElement(holdDuration: TimeInterval = 2, element: XCUIElement) {
        waitUntil(.visible).press(forDuration: holdDuration, thenDragTo: element)
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

    func find(idStartingWith idPrefix: String, label: String) -> XCUIElement {
        return descendants(matching: .any).matching(idStartingWith: idPrefix).matching(label: label).firstMatch
    }

    func find(idStartingWith idPrefix: String, labelContaining labelPart: String) -> XCUIElement {
        return descendants(matching: .any).matching(idStartingWith: idPrefix).matching(labelContaining: labelPart).firstMatch
    }

    func find(value: String, type: ElementType = .any) -> XCUIElement {
        return descendants(matching: type).matching(value: value).firstMatch
    }

    func find(placeholderValue: String, type: ElementType = .any) -> XCUIElement {
        return descendants(matching: type).matching(placeholderValue: placeholderValue).firstMatch
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

    func findAll(label: String, type: ElementType = .any) -> [XCUIElement] {
        return descendants(matching: type).matching(label: label).allElementsBoundByIndex
    }

    // MARK: Find alert functions

    func findAlertButton(label: String) -> XCUIElement {
        return descendants(matching: .alert).descendants(matching: .button).matching(label: label).firstMatch
    }

    func findAlertStaticText(label: String) -> XCUIElement {
        return descendants(matching: .alert).descendants(matching: .staticText).matching(label: label).firstMatch
    }
}
