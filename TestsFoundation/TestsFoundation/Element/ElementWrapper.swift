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
