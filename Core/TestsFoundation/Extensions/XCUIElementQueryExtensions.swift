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

public extension XCUIElementQuery {
    func matching(label: String) -> XCUIElementQuery {
        return matching(NSPredicate(format: "%K == %@", #keyPath(XCUIElement.label), label))
    }
    func matching(labelContaining needle: String) -> XCUIElementQuery {
        return matching(NSPredicate(format: "%K CONTAINS %@", #keyPath(XCUIElement.label), needle))
    }
    func matching(id: String) -> XCUIElementQuery {
        return matching(NSPredicate(format: "%K == %@", #keyPath(XCUIElement.identifier), id))
    }
    func matching(idStartingWith prefix: String) -> XCUIElementQuery {
        return matching(NSPredicate(format: "%K BEGINSWITH %@", #keyPath(XCUIElement.identifier), prefix))
    }
    func matching(value: String) -> XCUIElementQuery {
        return matching(NSPredicate(format: "%K == %@", #keyPath(XCUIElement.value), value))
    }
}
