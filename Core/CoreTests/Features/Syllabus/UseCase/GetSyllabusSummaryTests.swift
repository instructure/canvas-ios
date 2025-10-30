//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

class GetSyllabusSummaryTests: CoreTestCase {

    private let context: Context = .course("11")
    private var useCase: GetSyllabusSummary!

    override func setUp() {
        super.setUp()

        useCase = GetSyllabusSummary(context: context)

        mockApiData()
    }

    func testCacheKey() {
        XCTAssertEqual(useCase.cacheKey, "get-syllabus-summary-\(context.canvasContextID)")
    }

    func testFetchingData() {
        let exp = expectation(description: "fetch completion")
        useCase.fetch(environment: environment, force: true) { _, _, _ in
            exp.fulfill()
        }

        wait(for: [exp])

        // Plannable that belongs to another use case
        Plannable.save(
            APICalendarEvent.make(
                id: "4",
                title: "event",
                start_at: Date().addMinutes(2),
                type: .event,
                context_code: context.canvasContextID
            ),
            userId: nil,
            useCase: nil,
            in: databaseClient
        )

        let plannables = useCase.fetchFromDatabase(environment: environment)
        let receivedIDs = plannables.map(\.id)

        XCTAssertEqual(receivedIDs, ["1", "2", "6", "7", "8", "5"])
    }

    func testMakingRequests() {
        let exp = expectation(description: "request completion")
        var response: GetSyllabusSummary.Response?

        useCase.makeRequest(environment: environment) { res, _, _ in
            response = res
            exp.fulfill()
        }

        wait(for: [exp])

        XCTAssertEqual(response?.calendarEvents.map({ $0.id }), ["1", "5", "8", "2"])
        XCTAssertEqual(response?.plannables.map({ $0.plannable_id.value }), ["6", "7"])
    }

    // MARK: - Private helpers

    private func mockApiData() {
        let date = Date()

        api.mock(useCase.assignmentsRequest, value: [
            .make(
                id: "1",
                html_url: URL(string: "https://canvas.instructure.com/assignments/1")!,
                title: "assignment",
                start_at: date,
                type: .assignment,
                context_code: context.canvasContextID
            ),
            .make(
                id: "5",
                title: "nil date",
                start_at: nil,
                type: .assignment,
                context_code: context.canvasContextID
            )
        ])

        api.mock(useCase.subAssignmentsRequest, value: [
            .make(
                id: "8",
                html_url: URL(string: "https://canvas.instructure.com/assignments/8")!,
                title: "subassignment",
                start_at: date.addMinutes(8),
                type: .sub_assignment,
                context_code: context.canvasContextID
            )
        ])

        api.mock(useCase.eventsRequest, value: [
            .make(
                id: "2",
                title: "event",
                start_at: date.addMinutes(1),
                type: .event,
                context_code: context.canvasContextID
            ),
            .make(
                id: "3",
                title: "event",
                start_at: date.addMinutes(2),
                type: .event,
                context_code: context.canvasContextID,
                hidden: true
            )
        ])

        api.mock(useCase.ungradedItemsRequest, value: [
            .make(
                course_id: .init(context.id),
                context_type: context.contextType.rawValue,
                plannable_id: "6",
                plannable_type: "wiki_page",
                plannable: .make(title: "Random Page"),
                plannable_date: date.addMinutes(3)
            ),
            .make(
                course_id: .init(context.id),
                context_type: context.contextType.rawValue,
                plannable_id: "7",
                plannable_type: "discussion_topic",
                plannable: .make(title: "Discussion"),
                plannable_date: date.addMinutes(4)
            )
        ])
    }
}
