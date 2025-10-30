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

@testable import Horizon
@testable import Core
import XCTest
import Combine

final class GetHTimeSpentWidgetUseCaseTests: HorizonTestCase {

    private var testee: GetHTimeSpentWidgetUseCase!

    override func setUpWithError() throws {
        testee = GetHTimeSpentWidgetUseCase()
    }

    override func tearDownWithError() throws {
        testee = nil
    }

    func testCacheKey() {
        XCTAssertEqual(testee.cacheKey, "get-time-spent-widget")
    }

    func testMakeRequestSuccess() {
        // Given
        testee = GetHTimeSpentWidgetUseCase(journey: DomainServiceMock(result: .success(api)))
        let expectation = expectation(description: "Wait for completion")
        api.mock(
            DomainService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainService.JWTTokenRequest.Result(token: HTimeSpentWidgetStubs.token)
        )
        api.mock(GetHTimeSpentWidgetRequest(), value: HTimeSpentWidgetStubs.response)

        // When / Then
        testee.makeRequest(environment: environment) { response, _, _ in
            expectation.fulfill()
            let times = response?.data?.widgetData?.data
            XCTAssertEqual(times?.count, 5)
        }
        wait(for: [expectation], timeout: 0.2)
    }

    func testMakeRequestFail() {
        // Given
        let domainService = DomainServiceMock(result: .failure(DomainService.Issue.unableToGetToken))
        testee = GetHTimeSpentWidgetUseCase(journey: domainService)
        let expectation = expectation(description: "Wait for completion")
        api.mock(
            DomainService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainService.JWTTokenRequest.Result(token: HTimeSpentWidgetStubs.token),
            error: DomainService.Issue.unableToGetToken
        )
        api.mock(
            GetHTimeSpentWidgetRequest(),
            value: HTimeSpentWidgetStubs.response,
            error: DomainService.Issue.unableToGetToken
        )

        // When / Then
        testee.makeRequest(environment: environment) { response, _, error in
            expectation.fulfill()
            XCTAssertNil(response?.data?.widgetData?.data)
            XCTAssertEqual(error?.localizedDescription, DomainService.Issue.unableToGetToken.localizedDescription)
        }
        wait(for: [expectation], timeout: 0.2)
    }

    func testWriteResponseAggregatesMinutesByCourse() {
        // Given
        let response = HTimeSpentWidgetStubs.response

        // When
        testee.write(response: response, urlResponse: nil, to: databaseClient)
        let stored: [CDHTimeSpentWidgetModel] = databaseClient.fetch()
        let course1 = stored.first { $0.courseID == "C1" }
        let course2 = stored.first { $0.courseID == "C2" }
        let course3 = stored.first { $0.courseID == "C3" }

        // Then (C1 minutes should be 10 + 5 = 15)
        XCTAssertEqual(stored.count, 3)
        XCTAssertEqual(course1?.minutesPerDay.intValue, 15)
        XCTAssertEqual(course2?.minutesPerDay.intValue, 20)
        XCTAssertEqual(course3?.minutesPerDay.intValue, 0) // nil minutes defaulted to 0
    }

    func testScopeAll() {
        // Given
        testee.write(response: HTimeSpentWidgetStubs.response, urlResponse: nil, to: databaseClient)

        // When
        let fetched: [CDHTimeSpentWidgetModel] = databaseClient.fetch(scope: testee.scope)

        // Then
        XCTAssertEqual(fetched.count, 3)
    }
}
