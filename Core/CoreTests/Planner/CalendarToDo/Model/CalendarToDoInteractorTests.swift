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

@testable import Core
import Combine
import XCTest

final class CalendarToDoInteractorTests: CoreTestCase {

    private enum TestConstants {
        static let title = "some title"
        static let details = "some details"
        static let date = DateComponents(calendar: .current, year: 2024, month: 1, day: 1).date!
        static let courseID = "some courseID"
    }

    private var testee: CalendarToDoInteractorLive!

    override func setUp() {
        super.setUp()
        testee = .init()
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - GetToDo

    func testGetToDoWhenPlannableIsStored() {
        Plannable.save(.make(id: "7"), contextName: "context 7", in: databaseClient)
        Plannable.save(.make(id: "42"), contextName: "context 42", in: databaseClient)

        XCTAssertFirstValue(testee.getToDo(id: "42")) { plannable in
            XCTAssertEqual(plannable.id, "42")
            XCTAssertEqual(plannable.contextName, "context 42")
        }
    }

    func testGetToDoWhenPlannableIsNotStored() {
        Plannable.save(.make(id: "7"), contextName: nil, in: databaseClient)

        XCTAssertNoOutput(testee.getToDo(id: "42"))
    }

    // MARK: - CreateToDo

    func testCreateToDoParametersUseCaseProperly() {
        verifyCreateToDo(
            title: TestConstants.title,
            date: TestConstants.date,
            details: TestConstants.details
        ) { body in
            XCTAssertEqual(body.title, TestConstants.title)
            XCTAssertEqual(body.todo_date, TestConstants.date)
            XCTAssertEqual(body.course_id, nil)
            XCTAssertEqual(body.details, TestConstants.details)
        }
    }

    func testCreateToDoCourseIdWhenCalendarIsCourse() {
        let calendar = makeCalendar(context: .course(TestConstants.courseID))

        verifyCreateToDo(calendar: calendar) { body in
            XCTAssertEqual(body.course_id, TestConstants.courseID)
        }
    }

    func testCreateToDoCourseIdWhenCalendarIsGroup() {
        let calendar = makeCalendar(context: .group(TestConstants.courseID))

        verifyCreateToDo(calendar: calendar) { body in
            XCTAssertEqual(body.course_id, nil)
        }
    }

    func testCreateToDoCourseIdWhenCalendarIsUser() {
        let calendar = makeCalendar(context: .user(TestConstants.courseID))

        verifyCreateToDo(calendar: calendar) { body in
            XCTAssertEqual(body.course_id, nil)
        }
    }

    private func verifyCreateToDo(
        title: String = "",
        date: Date = Clock.now,
        calendar: CDCalendarFilterEntry? = nil,
        details: String? = nil,
        bodyHandler: @escaping (PostPlannerNoteRequest.Body) -> Void
    ) {
        let request = PostPlannerNoteRequest(body: .make())
        let expectation = XCTestExpectation(description: "Request was sent")
        mockRequest(request) { (body: PostPlannerNoteRequest.Body) in
            bodyHandler(body)
            expectation.fulfill()
        }

        let publisher = testee.createToDo(title: title, date: date, calendar: calendar, details: details)
        XCTAssertFinish(publisher)

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - UpdateToDo

    func testUpdateToDoParametersUseCaseProperly() {
        verifyUpdateToDo(
            title: TestConstants.title,
            date: TestConstants.date,
            details: TestConstants.details
        ) { body in
            XCTAssertEqual(body.title, TestConstants.title)
            XCTAssertEqual(body.todo_date, TestConstants.date)
            XCTAssertEqual(body.course_id, nil)
            XCTAssertEqual(body.details, TestConstants.details)
        }
    }

    func testUpdateToDoCourseIdWhenCalendarIsCourse() {
        let calendar = makeCalendar(context: .course(TestConstants.courseID))

        verifyUpdateToDo(calendar: calendar) { body in
            XCTAssertEqual(body.course_id, TestConstants.courseID)
        }
    }

    func testUpdateToDoCourseIdWhenCalendarIsGroup() {
        let calendar = makeCalendar(context: .group(TestConstants.courseID))

        verifyUpdateToDo(calendar: calendar) { body in
            XCTAssertEqual(body.course_id, nil)
        }
    }

    func testUpdateToDoCourseIdWhenCalendarIsUser() {
        let calendar = makeCalendar(context: .user(TestConstants.courseID))

        verifyUpdateToDo(calendar: calendar) { body in
            XCTAssertEqual(body.course_id, nil)
        }
    }

    private func verifyUpdateToDo(
        title: String = "",
        date: Date = Clock.now,
        calendar: CDCalendarFilterEntry? = nil,
        details: String? = nil,
        bodyHandler: @escaping (PutPlannerNoteRequest.Body) -> Void
    ) {
        let request = PutPlannerNoteRequest(id: "42", body: .make())
        let expectation = XCTestExpectation(description: "Request was sent")
        mockRequest(request) { (body: PutPlannerNoteRequest.Body) in
            bodyHandler(body)
            expectation.fulfill()
        }

        let publisher = testee.updateToDo(id: "42", title: title, date: date, calendar: calendar, details: details)
        XCTAssertFinish(publisher)

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - DeleteToDo

    func testDeleteToDo() {
        let request = DeletePlannerNoteRequest(id: "42")
        let expectation = XCTestExpectation(description: "Request was sent")
        api.mock(request) { _ in
            expectation.fulfill()
            return (nil, nil, nil)
        }

        let publisher = testee.deleteToDo(id: "42")
        XCTAssertFinish(publisher)

        wait(for: [expectation], timeout: 1)
    }

    // MARK: - Helpers

    private func mockRequest<Request: APIRequestable, Body: Codable & Equatable>(
        _ request: Request,
        dataHandler: @escaping (Body) -> Void
    ) {
        api.mock(request) { urlRequest in
            guard let body: Body = urlRequest.decodeBody() else {
                XCTFail("Request body decoding failure")
                return (nil, nil, nil)
            }
            dataHandler(body)
            return (nil, nil, nil)
        }
    }

    private func makeCalendar(
        name: String = "",
        context: Context
    ) -> CDCalendarFilterEntry {
        let calendar: CDCalendarFilterEntry = databaseClient.insert()
        calendar.name = ""
        calendar.context = context
        return calendar
    }
}
