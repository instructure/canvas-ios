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
@testable import Core

class TodoListTests: CoreUITestCase {
    override var abstractTestClass: CoreUITestCase.Type { return TodoListTests.self }

    func testTodoItemsDisplayed() {
        mockBaseRequests()
        mockData(GetCoursesRequest(enrollmentState: .active), value: [ baseCourse ])
        mockData(GetGroupsRequest(context: .currentUser), value: [])
        mockData(GetTodosRequest(), value: [
            APITodo.make(assignment: .make(name: "One", due_at: Date().add(.day, number: 1))),
            APITodo.make(assignment: .make(id: "2", name: "Two")),
        ])

        logIn()
        TabBar.todoTab.tap()

        app.find(labelContaining: "One").waitToExist()
        app.find(labelContaining: "Two").waitToExist()
        app.find(labelContaining: "Due").waitToExist()
        app.find(labelContaining: "No Due Date").waitToExist()
    }
}
