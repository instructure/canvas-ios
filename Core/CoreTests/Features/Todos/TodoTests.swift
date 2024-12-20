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
@testable import Core
import TestsFoundation

class TodoTests: CoreTestCase {
    func testContext() {
        XCTAssertEqual(Todo.make(from: .make(course_id: nil, group_id: "1")).contextRaw, "group_1")
        let todo = Todo.make(from: .make(course_id: "1", group_id: nil))
        XCTAssertEqual(todo.contextRaw, "course_1")
        todo.contextRaw = "course_7"
        XCTAssertEqual(todo.context.id, "7")
        todo.contextRaw = "bogus"
        XCTAssertEqual(todo.context.canvasContextID, "user_self")
    }

    func testType() {
        let todo = Todo.make()
        todo.type = .submitting
        XCTAssertEqual(todo.type, TodoType.submitting)
        XCTAssertEqual(todo.typeRaw, TodoType.submitting.rawValue)

        todo.typeRaw = "bogus"
        XCTAssertEqual(todo.type, TodoType.submitting)
    }

    func testScope() {
        let usecase = GetTodos()
        XCTAssertEqual(usecase.scope.predicate, .all)
        let gradingTodoType: TodoType = .grading
        let gradingUsecase = GetTodos(gradingTodoType)
        XCTAssertEqual(gradingUsecase.scope.predicate, NSPredicate(format: "%K == %@", #keyPath(Todo.typeRaw), gradingTodoType.rawValue))
        let submittingTodoType: TodoType = .submitting
        let submittingUsecase = GetTodos(submittingTodoType)
        XCTAssertEqual(submittingUsecase.scope.predicate, NSPredicate(format: "%K == %@", #keyPath(Todo.typeRaw), submittingTodoType.rawValue))

    }

    func testCourse() {
        let todo = Todo.make(from: .make(course_id: "1", group_id: nil))
        XCTAssertNil(todo.course)
        XCTAssertNil(todo.group)
        Course.make()
        XCTAssertNotNil(todo.getCourse())
        XCTAssertNotNil(todo.course)
    }

    func testGroup() {
        let todo = Todo.make(from: .make(course_id: nil, group_id: "1"))
        XCTAssertNil(todo.course)
        XCTAssertNil(todo.group)
        Group.make()
        XCTAssertNotNil(todo.getGroup())
        XCTAssertNotNil(todo.group)
    }

    func testNoDueDateString() {
        let todo = Todo.make(from: .make(course_id: "1", group_id: nil))
        XCTAssertEqual(todo.dueText, "No Due Date")
    }

    func testNearFutureDueDateString() {
        let dateTomorrow = Date().addDays(1)
        let todo = Todo.make(from: .make(assignment: .make(due_at: dateTomorrow), course_id: "1", group_id: nil))
        XCTAssertEqual(todo.dueText, "Due " + dateTomorrow.relativeDateTimeStringWithDayOfWeek)
    }

    func testDistantDueDateString() {
        let todo = Todo.make(from: .make(assignment: .make(due_at: Date(timeIntervalSince1970: 23022000)), course_id: "1", group_id: nil))
        XCTAssertTrue(todo.dueText.hasPrefix("Due Thursday, "))
        XCTAssertTrue(todo.dueText.contains("September"))
        XCTAssertTrue(todo.dueText.contains("24"))
        XCTAssertTrue(todo.dueText.contains("1970"))
        XCTAssertTrue(todo.dueText.contains(":00"))
    }
}
