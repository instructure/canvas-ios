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

public var app: XCUIApplication {
    return XCUIApplication()
}

// Enable defining enums that have a string element id and then invoking methods on them.
//
//  enum LoginPage: String, CaseIterable, ElementWrapper {
//      case resetPassword
//  }
public protocol ElementWrapper: Element {
    var element: Element { get }
}

// Provide default implementation for enums
public extension ElementWrapper where Self: RawRepresentable, Self.RawValue: StringProtocol {
    var element: Element {
        return app.find(id: id)
    }
    var id: String {
        return "\(String(describing: Self.self)).\(rawValue)"
    }
}

public extension ElementWrapper {
    var elementType: XCUIElement.ElementType {
        return element.elementType
    }
    var exists: Bool {
        return element.exists
    }
    var frame: CGRect {
        return element.frame
    }
    var id: String {
        return element.id
    }
    var isEnabled: Bool {
        return element.isEnabled
    }
    var isSelected: Bool {
        return element.isSelected
    }
    var isVisible: Bool {
        return element.isVisible
    }
    var label: String {
        return element.label
    }
    var value: String {
        return element.value
    }

    @discardableResult
    func pick(column: Int, value: String, file: StaticString, line: UInt) -> Element {
        return element.pick(column: column, value: value, file: file, line: line)
    }

    @discardableResult
    func tap(file: StaticString, line: UInt) -> Element {
        return element.tap(file: file, line: line)
    }

    @discardableResult
    func tapAt(_ point: CGPoint, file: StaticString, line: UInt) -> Element {
        return element.tapAt(point, file: file, line: line)
    }

    @discardableResult
    func typeText(_ text: String, file: StaticString, line: UInt) -> Element {
        return element.typeText(text, file: file, line: line)
    }

    @discardableResult
    func swipeDown(file: StaticString, line: UInt) -> Element {
        return element.swipeDown(file: file, line: line)
    }

    @discardableResult
    func swipeUp(file: StaticString, line: UInt) -> Element {
        return element.swipeUp(file: file, line: line)
    }

    @discardableResult
    func waitToExist(_ timeout: TimeInterval, file: StaticString, line: UInt) -> Element {
        return element.waitToExist(timeout, file: file, line: line)
    }

    @discardableResult
    func waitToVanish(_ timeout: TimeInterval, file: StaticString, line: UInt) -> Element {
        return element.waitToVanish(timeout, file: file, line: line)
    }
}
