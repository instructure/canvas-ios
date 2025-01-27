//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

final class CreatePlannerNoteTests: CoreTestCase {

    private enum TestConstants {
        static let title = "some title"
        static let details = "some details"
        static let todoDate = Clock.now
        static let courseId = "some courseId"
        static let courseName = "some courseName"

        static let responseId = "response id"
        static let responseTitle = "response title"
        static let responseDetails = "response details"
        static let responseTodoDate = Clock.now.inCalendar.addDays(1)
        static let responseCourseId = "response courseId"
        static let responseUserId = "response userId"
    }

    private var testee: CreatePlannerNote!

    override func setUp() {
        super.setUp()
        testee = .init(
            title: TestConstants.title,
            details: TestConstants.details,
            todoDate: TestConstants.todoDate,
            courseID: TestConstants.courseId,
            courseName: TestConstants.courseName
        )
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    func testRequest() {
        let body = testee.request.body
        XCTAssertEqual(body?.title, TestConstants.title)
        XCTAssertEqual(body?.details, TestConstants.details)
        XCTAssertEqual(body?.todo_date, TestConstants.todoDate)
        XCTAssertEqual(body?.course_id, TestConstants.courseId)
        XCTAssertEqual(body?.linked_object_type, .planner_note)
        XCTAssertEqual(body?.linked_object_id, nil)
    }

    func testWrite() {
        let response = APIPlannerNote.make(
            id: TestConstants.responseId,
            title: TestConstants.responseTitle,
            details: TestConstants.responseDetails,
            todo_date: TestConstants.responseTodoDate,
            user_id: TestConstants.responseUserId,
            course_id: TestConstants.responseCourseId
        )

        testee.write(response: response, urlResponse: nil, to: databaseClient)
        let model: Plannable? = databaseClient.first(where: #keyPath(Plannable.id), equals: TestConstants.responseId)

        XCTAssertEqual(model?.contextName, TestConstants.courseName)

        XCTAssertEqual(model?.title, TestConstants.responseTitle)
        XCTAssertEqual(model?.details, TestConstants.responseDetails)
        XCTAssertEqual(model?.date, TestConstants.responseTodoDate)
        XCTAssertEqual(model?.userID, TestConstants.responseUserId)
        XCTAssertEqual(model?.context?.courseId, TestConstants.responseCourseId)
    }
}
