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

import XCTest
import TestsFoundation

enum Modules {
    static func module(index: Int) -> Element {
        return app.find(id: "module_cell_0_\(index)")
    }
}

enum ModulesDetail {
    static func module(index: Int) -> Element {
        return app.find(id: "module_cell_0_\(index)")
    }

    static func moduleItem(index: Int) -> Element {
        return app.find(id: "module_item_cell_0_\(index)")
    }
}

enum ModuleItemNavigation {
    static var nextButton: Element {
        return app.find(id: "next_module_item_button")
    }

    static var previousButton: Element {
        return app.find(id: "previous_module_item_button")
    }

    static var backButton: Element {
        return app.find(labelContaining: "Assignment Module")
    }
}
