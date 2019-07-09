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

enum GradesList {
    static var title: Element {
        return app.find(label: "Grades")
    }

    static func assignment(id: String) -> Element {
        return app.find(id: "grades-list.grades-list-row.cell-\(id)")
    }
}

enum AssignmentDetails {
    static func description(_ description: String) -> Element {
        return app.find(label: description)
    }

    static func link(_ description: String) -> Element {
        return XCUIElementWrapper(app.webViews.staticTexts[description])
    }
}
