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

@testable import Core
import XCTest

class MarkPlannableItemDoneTests: CoreTestCase {

    func test_makeRequest_createsOverrideSuccessfully() {
        let plannable = Plannable.save(
            APIPlannable.make(plannable_id: ID("123")),
            userId: nil,
            in: databaseClient
        )

        XCTAssertNil(plannable.isMarkedComplete)
        XCTAssertNil(plannable.plannerOverrideId)

        let useCase = MarkPlannableItemDone(
            plannableId: "123",
            plannableType: "assignment",
            overrideId: nil,
            done: true
        )

        let createRequest = CreatePlannerOverrideRequest(
            body: .init(
                plannable_type: "assignment",
                plannable_id: "123",
                marked_complete: true
            )
        )
        let mockResponse = APIPlannerOverride.make(
            id: "override-789",
            marked_complete: true
        )
        api.mock(createRequest, value: mockResponse)

        let expectation = XCTestExpectation(description: "request completes")
        useCase.makeRequest(environment: environment) { response, _, error in
            XCTAssertNil(error)
            XCTAssertEqual(response?.id.value, "override-789")
            useCase.write(response: response, urlResponse: nil, to: self.databaseClient)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        databaseClient.refresh()

        XCTAssertEqual(plannable.isMarkedComplete, true)
        XCTAssertEqual(plannable.plannerOverrideId, "override-789")
    }

    func test_makeRequest_updatesOverrideSuccessfully() {
        let plannable = Plannable.save(
            APIPlannable.make(
                planner_override: .make(id: "override-123", marked_complete: true),
                plannable_id: ID("123")
            ),
            userId: nil,
            in: databaseClient
        )

        XCTAssertEqual(plannable.isMarkedComplete, true)
        XCTAssertEqual(plannable.plannerOverrideId, "override-123")

        let useCase = MarkPlannableItemDone(
            plannableId: "123",
            plannableType: "assignment",
            overrideId: "override-123",
            done: false
        )

        let updateRequest = UpdatePlannerOverrideRequest(
            overrideId: "override-123",
            body: .init(marked_complete: false)
        )
        api.mock(updateRequest, value: APIPlannerOverride.make(
            id: "override-123",
            plannable_type: "assignment",
            plannable_id: ID("123"),
            marked_complete: false
        ))

        let expectation = XCTestExpectation(description: "request completes")
        useCase.makeRequest(environment: environment) { response, _, error in
            XCTAssertNil(error)
            XCTAssertEqual(response?.id.value, "override-123")
            XCTAssertEqual(response?.marked_complete, false)
            useCase.write(response: response, urlResponse: nil, to: self.databaseClient)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        databaseClient.refresh()

        XCTAssertEqual(plannable.isMarkedComplete, false)
        XCTAssertEqual(plannable.plannerOverrideId, "override-123")
    }

    func test_makeRequest_onError_doesNotUpdateDatabase() {
        let plannable = Plannable.save(
            APIPlannable.make(plannable_id: ID("123")),
            userId: nil,
            in: databaseClient
        )

        XCTAssertNil(plannable.isMarkedComplete)

        let useCase = MarkPlannableItemDone(
            plannableId: "123",
            plannableType: "assignment",
            overrideId: nil,
            done: true
        )

        let createRequest = CreatePlannerOverrideRequest(
            body: .init(
                plannable_type: "assignment",
                plannable_id: "123",
                marked_complete: true
            )
        )
        api.mock(createRequest, error: NSError.instructureError("test error"))

        let expectation = XCTestExpectation(description: "request completes")
        useCase.makeRequest(environment: environment) { response, _, error in
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
        databaseClient.refresh()

        XCTAssertNil(plannable.isMarkedComplete)
        XCTAssertNil(plannable.plannerOverrideId)
    }

    func test_cacheKey_isNil() {
        let useCase = MarkPlannableItemDone(
            plannableId: "123",
            plannableType: "assignment",
            overrideId: nil,
            done: true
        )

        XCTAssertNil(useCase.cacheKey)
    }

    func test_scope_usesPlannableId() {
        let useCase = MarkPlannableItemDone(
            plannableId: "123",
            plannableType: "assignment",
            overrideId: nil,
            done: true
        )

        XCTAssertEqual(useCase.scope, .plannable(id: "123"))
    }
}
