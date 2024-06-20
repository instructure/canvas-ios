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

final class CreateToDoInteractorTests: CoreTestCase {

    private enum TestConstants {
        static let title = "some title"
        static let details = "some details"
        static let date = DateComponents(calendar: .current, year: 2024, month: 1, day: 1).date!
        static let courseID = "some courseID"
    }

    private var useCase: CreatePlannerNote!
    private var testee: CreateToDoInteractorLive!

    override func setUp() {
        super.setUp()
        useCase = .init(todoDate: .now)
        testee = .init()
    }

    override func tearDown() {
        useCase = nil
        testee = nil
        super.tearDown()
    }

    func testCreateToDoProperRequestIsMade() {
        let expectation = XCTestExpectation(description: "Proper request is made")
        api.mock(useCase.request) { _ in
            expectation.fulfill()
            return (nil, nil, nil)
        }

        let subscription = testee.createToDo(title: "", date: .now, calendar: nil, details: nil)
            .sink()

        wait(for: [expectation], timeout: 1)
        subscription.cancel()
    }

    func testCreateToDoParametersUseCaseProperly() {
        api.mock(useCase.request) { request in
            let body: PostPlannerNoteRequest.Body? = request.decodeBody()

            XCTAssertEqual(body?.title, TestConstants.title)
            XCTAssertEqual(body?.todo_date, TestConstants.date)
            XCTAssertEqual(body?.course_id, nil)
            XCTAssertEqual(body?.details, TestConstants.details)
            return (nil, nil, nil)
        }

        let subscription = testee.createToDo(
            title: TestConstants.title,
            date: TestConstants.date,
            calendar: nil,
            details: TestConstants.details
        ).sink()

        subscription.cancel()
    }

    func testCreateToDoCourseIdWhenCalendarIsCourse() {
        let calendar: CDCalendarFilterEntry = databaseClient.insert()
        calendar.context = .course(TestConstants.courseID)

        api.mock(useCase.request) { request in
            let body: PostPlannerNoteRequest.Body? = request.decodeBody()

            XCTAssertEqual(body?.course_id, TestConstants.courseID)
            return (nil, nil, nil)
        }

        let subscription = testee.createToDo(title: "", date: .now, calendar: calendar, details: nil)
            .sink()

        subscription.cancel()
    }

    func testCreateToDoCourseIdWhenCalendarIsGroup() {
        let calendar: CDCalendarFilterEntry = databaseClient.insert()
        calendar.context = .group(TestConstants.courseID)

        api.mock(useCase.request) { request in
            let body: PostPlannerNoteRequest.Body? = request.decodeBody()

            XCTAssertNotNil(body)
            XCTAssertEqual(body?.course_id, nil)
            return (nil, nil, nil)
        }

        let subscription = testee.createToDo(title: "", date: .now, calendar: calendar, details: nil)
            .sink()

        subscription.cancel()
    }

    func testCreateToDoCourseIdWhenCalendarIsUser() {
        let calendar: CDCalendarFilterEntry = databaseClient.insert()
        calendar.context = .user(TestConstants.courseID)

        api.mock(useCase.request) { request in
            let body: PostPlannerNoteRequest.Body? = request.decodeBody()

            XCTAssertNotNil(body)
            XCTAssertEqual(body?.course_id, nil)
            return (nil, nil, nil)
        }

        let subscription = testee.createToDo(title: "", date: .now, calendar: calendar, details: nil)
            .sink()

        subscription.cancel()
    }
}
