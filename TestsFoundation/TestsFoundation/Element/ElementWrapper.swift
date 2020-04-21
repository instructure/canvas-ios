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
    var typeName: String { get }
    var id: String { get }
}

public extension ElementWrapper {
    var element: Element {
        app.find(id: id)
    }

    var typeName: String { String(describing: Self.self) }

    var queryWrapper: XCUIElementQueryWrapper {
        element.queryWrapper
    }
}

// Allow for enums with fully customizable string contents
//
//  enum Inbox: String, CaseIterable, RawElementWrapper {
//      case sentButton = "inbox.filter-btn-sent"
//  }
public protocol RawElementWrapper: ElementWrapper {}

// Provide default implementation for enums
public extension ElementWrapper where Self: RawRepresentable, Self.RawValue: StringProtocol {
    var element: Element {
        app.find(id: id)
    }
    var id: String {
        "\(typeName).\(rawValue)"
    }
}

public extension RawElementWrapper where Self: RawRepresentable, Self.RawValue: StringProtocol {
    var element: Element {
        app.find(id: id)
    }
    var id: String { "\(rawValue)" }
}
