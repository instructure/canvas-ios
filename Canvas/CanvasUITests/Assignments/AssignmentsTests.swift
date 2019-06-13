//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import SwiftUITest
import XCTest

enum CourseDetails {
    static var grades: Element {
        return app.find(id: "courses-details.grades-cell")
    }
}

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
}

class AssignmentsTests: CanvasUITests {
    override var user: User? { return .student1 }

    func testViewAssignment() {
        let card = Dashboard.courseCard(id: "263")
        card.waitToExist(Timeout())
        card.tap()
        CourseDetails.grades.waitToExist(Timeout())
        CourseDetails.grades.tap()

        let row = GradesList.assignment(id: "1831")
        row.waitToExist(Timeout())
        row.tap()

        AssignmentDetails.description("This is assignment one.").waitToExist(Timeout())
    }
}
