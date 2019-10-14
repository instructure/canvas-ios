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

// warning: These functions will actually use `app` for finding elements,
// so will only function properly on the test target app.
public extension XCUIApplication {
    func find(label: String, type: XCUIElement.ElementType = .any) -> Element {
        return app.descendants(matching: type).matching(label: label).firstElement
    }

    func find(labelContaining needle: String, type: XCUIElement.ElementType = .any) -> Element {
        return app.descendants(matching: type).matching(labelContaining: needle).firstElement
    }

    func find(id: String, type: XCUIElement.ElementType = .any) -> Element {
        return app.descendants(matching: type).matching(id: id).firstElement
    }

    func find(value: String, type: XCUIElement.ElementType = .any) -> Element {
        return app.descendants(matching: type).matching(value: value).firstElement
    }

    func find(type: XCUIElement.ElementType, index: Int = 0) -> Element {
        return XCUIElementQueryWrapper(app.descendants(matching: type), index: index)
    }
}
