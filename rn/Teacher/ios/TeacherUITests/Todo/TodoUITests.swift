//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

import TestsFoundation
@testable import Core

class TodoUITests: MiniCanvasUITestCase {
    override func setUpState() {
        super.setUpState()
        let course = mocked.courses[0]
        for assignment in course.assignments {
            mocked.todos.append(APITodo.make(
                type: .grading,
                html_url: assignment.api.html_url,
                needs_grading_count: 2,
                assignment: assignment.api,
                course_id: course.api.id
            ))
        }
    }

    func testTodos() {
        XCTAssertEqual(TabBar.todoTab.value(), "8 items")
        TabBar.todoTab.tap()

        let assignment = mocked.courses[0].assignments[0]
        let row = app.find(id: "to-do.list.\(assignment.api.html_url).row")
        XCTAssertEqual(row.label(), "Published Assignment 1 Course One No Due Date 2 NEED GRADING")

        row.tap()
        SpeedGrader.dismissTutorial()
        app.find(label: "A submission from Student 10").waitToExist()
    }
}
