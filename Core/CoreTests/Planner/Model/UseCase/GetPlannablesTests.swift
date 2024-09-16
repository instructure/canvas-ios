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

import XCTest
@testable import Core

class GetPlannablesTests: CoreTestCase {

    var start = Clock.now
    var end = Clock.now.addDays(1)
    var userID: String?
    var contextCodes: [String]?

    func makeUseCase() -> GetPlannables {
        GetPlannables(userID: userID, startDate: start, endDate: end, contextCodes: contextCodes)
    }

    lazy var useCase: GetPlannables = makeUseCase()

    func testCacheKey() {
        XCTAssertEqual(useCase.cacheKey, "get-plannables--\(start)-\(end)--")
    }

    func testScope() {
        let first = Plannable.make(from: .make(
            plannable_id: "1",
            plannable: APIPlannable.plannable(details: "", title: "a"),
            plannable_date: start
        ))
        let second = Plannable.make(from: .make(
            plannable_id: "2",
            plannable: APIPlannable.plannable(details: "", title: "b"),
            plannable_date: start
        ))
        let third = Plannable.make(from: .make(
            plannable_id: "3",
            plannable: APIPlannable.plannable(details: "", title: "c"),
            plannable_date: start.addMinutes(1)
        ))
        let other = Plannable.make(from: .make(
            plannable_id: "4",
            plannable: APIPlannable.plannable(details: "", title: "d"),
            plannable_date: end.addDays(1)
        ))
        XCTAssertTrue([first, second, third].allSatisfy(useCase.scope.predicate.evaluate(with:)))
        XCTAssertFalse(useCase.scope.predicate.evaluate(with: other))
        let plannables: [Plannable] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(plannables, [first, second, third])
    }

    func testScopeWithUserID() {
        let yes = Plannable.make(from: .make(plannable_id: "1"), userID: "1")
        Plannable.make(from: .make(plannable_id: "2"), userID: nil)
        Plannable.make(from: .make(plannable_id: "3"), userID: "2")
        useCase = GetPlannables(userID: "1", startDate: start, endDate: end)
        let plannables: [Plannable] = databaseClient.fetch(scope: useCase.scope)
        XCTAssertEqual(plannables, [yes])
    }

    func testMakeRequest() {
        api.mock(GetPlannablesRequest(
            userID: nil,
            startDate: start,
            endDate: end,
            contextCodes: ["course_1"]
        ), value: [.make(plannable_id: "1")])
        let expectation = XCTestExpectation(description: "callback")
        let useCase = GetPlannables(userID: userID, startDate: start, endDate: end, contextCodes: ["course_1"])
        useCase.makeRequest(environment: environment) { response, _, _ in
            XCTAssertEqual(response?.plannables?.first?.plannable_id, "1")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMakeRequestWithoutContextCodes() {
        api.mock(GetPlannablesRequest(
            userID: nil,
            startDate: start,
            endDate: end,
            contextCodes: []
        ), value: [.make(plannable_id: "1")])
        let expectation = XCTestExpectation(description: "callback")
        useCase.makeRequest(environment: environment) { response, _, _ in
            XCTAssertEqual(response!.plannables, [])
            XCTAssertEqual(response!.calendarEvents, [])
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMakeRequestParentApp() {
        environment.app = .parent
        contextCodes = ["course_1"]
        let studentID = "1"
        api.mock(GetCoursesRequest(
            enrollmentState: .active,
            enrollmentType: .observer,
            state: [.available],
            perPage: 100
        ), value: [.make(id: "1", enrollments: [.make(id: "1", associated_user_id: studentID)])])
        api.mock(GetCalendarEventsRequest(
            contexts: [Context(.course, id: "1")],
            startDate: start,
            endDate: end,
            type: .event,
            include: [.submission],
            allEvents: false,
            userID: userID
        ), value: [.make(id: "1", type: .event)])
        api.mock(GetCalendarEventsRequest(
            contexts: [Context(.course, id: "1")],
            startDate: start,
            endDate: end,
            type: .assignment,
            include: [.submission],
            allEvents: false,
            userID: userID
        ), value: [.make(id: "2", type: .assignment)])
        let expectation = XCTestExpectation(description: "callback")
        useCase.makeRequest(environment: environment) { response, _, _ in
            XCTAssertEqual(response?.calendarEvents?[0].type, .event)
            XCTAssertEqual(response?.calendarEvents?[1].type, .assignment)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testMakeRequestTeacherApp() {
        // Given - Teacher
        environment.app = .teacher
        contextCodes = ["course_1"]

        /// Courses
        api.mock(GetCoursesRequest(
            enrollmentState: .active,
            enrollmentType: .observer,
            state: [.available],
            perPage: 100
        ), value: [.make(id: "1", enrollments: [.make(id: "1", associated_user_id: "1")])])

        /// Calendar Events
        api.mock(GetCalendarEventsRequest(
            contexts: [Context(.course, id: "1")],
            startDate: start,
            endDate: end,
            type: .event,
            include: [.submission],
            allEvents: false,
            userID: userID
        ), value: [.make(id: "1", type: .event)])

        api.mock(GetCalendarEventsRequest(
            contexts: [Context(.course, id: "1")],
            startDate: start,
            endDate: end,
            type: .assignment,
            include: [.submission],
            allEvents: false,
            userID: userID
        ), value: [.make(id: "2", type: .assignment)])

        /// Planner Notes
        api.mock(GetPlannerNotesRequest(
            contexts: [Context(.course, id: "1")],
            startDate: start,
            endDate: end
        ), value: [.make(id: "33", title: "Planner Note", details: "Details")])

        let expectation = XCTestExpectation(description: "callback")
        useCase.makeRequest(environment: environment) { response, _, _ in
            XCTAssertEqual(response?.calendarEvents?.count, 2)
            XCTAssertEqual(response?.plannerNotes?.count, 1)

            XCTAssertEqual(response?.calendarEvents?[0].type, .event)
            XCTAssertEqual(response?.calendarEvents?[1].type, .assignment)

            XCTAssertEqual(response?.plannerNotes?[0].id, "33")
            XCTAssertEqual(response?.plannerNotes?[0].title, "Planner Note")
            XCTAssertEqual(response?.plannerNotes?[0].details, "Details")

            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        // Given - Parent
        environment.app = .parent
        contextCodes = ["course_1"]

        // Then
        let expectation2 = XCTestExpectation(description: "parent-callback")
        useCase.makeRequest(environment: environment) { response, _, _ in
            XCTAssertEqual(response?.calendarEvents?.count, 2)
            XCTAssertEqual(response?.plannerNotes?.count, 0)

            XCTAssertEqual(response?.calendarEvents?[0].type, .event)
            XCTAssertEqual(response?.calendarEvents?[1].type, .assignment)

            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1)
    }

    func testWriteCalendarEvents() {
        let response = GetPlannables.Response.init(calendarEvents: [
            .make(id: "1", start_at: start, hidden: false),
            .make(id: "2", start_at: start, hidden: true)
        ])
        useCase.write(response: response, urlResponse: nil, to: databaseClient)
        let plannables = databaseClient.fetch(scope: useCase.scope) as [Plannable]
        XCTAssertEqual(plannables.count, 1)
        XCTAssertEqual(plannables.first?.id, "1")
    }

    func testWritePlannerNotes() {
        let response = GetPlannables.Response.init(plannerNotes: [
            .make(id: "44", todo_date: start),
            .make(id: "76", todo_date: start.addHours(3))
        ])

        useCase.write(response: response, urlResponse: nil, to: databaseClient)
        let plannables = databaseClient.fetch(scope: useCase.scope) as [Plannable]

        XCTAssertEqual(plannables.count, 2)
        XCTAssertEqual(plannables[safeIndex: 0]?.id, "44")
        XCTAssertEqual(plannables[safeIndex: 1]?.id, "76")
    }
}
