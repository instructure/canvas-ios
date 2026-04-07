//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

final class GetAnalyticsConsentTests: CoreTestCase {

    private static let studentRequest = GetAnalyticsConsentRequest(namespace: .student)

    // MARK: - cacheKey

    func test_cacheKey() {
        let testee = GetAnalyticsConsent(app: .student)
        XCTAssertEqual(testee.cacheKey, "get-analytics-consent")
    }

    // MARK: - request

    func test_request_shouldUseAppConsentNamespace() {
        var testee = GetAnalyticsConsent(app: .student)
        XCTAssertEqual(testee.request.namespace, .student)

        testee = GetAnalyticsConsent(app: .horizon)
        XCTAssertEqual(testee.request.namespace, .student)

        testee = GetAnalyticsConsent(app: .teacher)
        XCTAssertEqual(testee.request.namespace, .teacher)

        testee = GetAnalyticsConsent(app: .parent)
        XCTAssertEqual(testee.request.namespace, .parent)
    }

    // MARK: - makeRequest

    func test_makeRequest_whenAPIReturnsValidResponse_shouldForwardResponse() {
        let response = APIAnalyticsConsent.make(data: .init(mobile_consent: true))
        api.mock(Self.studentRequest, value: response)
        let testee = GetAnalyticsConsent(app: .student)

        let responseReceived = expectation(description: "response received")
        testee.makeRequest(environment: environment) { result, _, error in
            XCTAssertEqual(result, response)
            XCTAssertNil(error)
            responseReceived.fulfill()
        }

        wait(for: [responseReceived], timeout: 1)
    }

    func test_makeRequest_whenAPIReturnsNoDataMessage_shouldForwardResponse() {
        let response = APIAnalyticsConsent.make(message: APIAnalyticsConsent.noDataMessage)
        api.mock(Self.studentRequest, value: response)
        let testee = GetAnalyticsConsent(app: .student)

        let responseReceived = expectation(description: "response received")
        testee.makeRequest(environment: environment) { result, _, error in
            XCTAssertEqual(result, response)
            XCTAssertNil(error)
            responseReceived.fulfill()
        }

        wait(for: [responseReceived], timeout: 1)
    }

    func test_makeRequest_whenAPIReturnsInvalidResponse_shouldReturnError() {
        let invalidResponse = APIAnalyticsConsent.make()
        api.mock(Self.studentRequest, value: invalidResponse)
        let testee = GetAnalyticsConsent(app: .student)

        let responseReceived = expectation(description: "response received")
        testee.makeRequest(environment: environment) { result, _, error in
            XCTAssertEqual(result, nil)
            XCTAssertNotNil(error)
            responseReceived.fulfill()
        }

        wait(for: [responseReceived], timeout: 1)
    }

    func test_makeRequest_whenAPIReturnsError_shouldForwardError() {
        let expectedError = NSError.instructureError("some api error")
        api.mock(Self.studentRequest, value: nil, error: expectedError)
        let testee = GetAnalyticsConsent(app: .student)

        let responseReceived = expectation(description: "response received")
        testee.makeRequest(environment: environment) { result, _, error in
            XCTAssertEqual(result, nil)
            XCTAssertNotNil(error)
            responseReceived.fulfill()
        }

        wait(for: [responseReceived], timeout: 1)
    }
}
