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

public extension XCUIElement {
    func find(label: String, type: XCUIElement.ElementType = .any) -> Element {
        return descendants(matching: type).matching(label: label).firstElement
    }

    func find(labelContaining needle: String, type: XCUIElement.ElementType = .any) -> Element {
        return descendants(matching: type).matching(labelContaining: needle).firstElement
    }

    func find(id: String, type: XCUIElement.ElementType = .any) -> Element {
        return descendants(matching: type).matching(id: id).firstElement
    }

    func find(idStartingWith prefix: String, type: XCUIElement.ElementType = .any) -> Element {
        return descendants(matching: type).matching(idStartingWith: prefix).firstElement
    }

    func find(value: String, type: XCUIElement.ElementType = .any) -> Element {
        return descendants(matching: type).matching(value: value).firstElement
    }

    func find(type: XCUIElement.ElementType, index: Int = 0) -> Element {
        return XCUIElementQueryWrapper(descendants(matching: type), index: index)
    }

    func find(id: String, label: String, type: XCUIElement.ElementType = .any) -> Element {
        return descendants(matching: type).matching(id: id).matching(label: label).firstElement
    }

    func findAll(type: XCUIElement.ElementType) -> [Element] {
        XCUIElementQueryWrapper(descendants(matching: type)).allElements
    }

    func findAll(labelContaining: String, type: XCUIElement.ElementType = .any) -> [Element] {
        XCUIElementQueryWrapper(descendants(matching: type).matching(labelContaining: labelContaining)).allElements
    }

    // MARK: - Alerts

    func findAlertButton(label: String) -> Element {
        descendants(matching: .alert).descendants(matching: .button).matching(label: label).firstElement
    }

    func findAlertStaticText(label: String) -> Element {
        descendants(matching: .alert).descendants(matching: .staticText).matching(label: label).firstElement
    }
}
