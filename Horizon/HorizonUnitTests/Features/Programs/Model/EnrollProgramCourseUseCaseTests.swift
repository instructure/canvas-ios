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

final class EnrollProgramCourseUseCaseTests: HorizonTestCase {
    func testCacheKey() {
        // Given
        let testee = EnrollProgramCourseUseCase(progressId: "123", journey: DomainServiceMock(result: .success(api)))
        // Then
        XCTAssertNil(testee.cacheKey)
    }

    func testMakeRequestSuccessResponse() {
        // Given
        let testee = EnrollProgramCourseUseCase(progressId: "123", journey: DomainServiceMock(result: .success(api)))
        let expection = expectation(description: "Wait for completion")

        // When
        api.mock(
            DomainService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainService.JWTTokenRequest.Result(token: HProgramStubs.token)
        )

        // Then
        testee.makeRequest(environment: environment) { response, _, _ in
            expection.fulfill()
            XCTAssertNil(response)
        }
        wait(for: [expection], timeout: 0.2)
    }

    func testMakeRequestFailureResponse() {
        // Given
        let testee = EnrollProgramCourseUseCase(
            progressId: "123",
            journey: DomainServiceMock(
                result: .failure(DomainService.Issue.unableToGetToken)
            )
        )
        let expection = expectation(description: "Wait for completion")

        // When
        api.mock(
            DomainService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainService.JWTTokenRequest.Result(token: HProgramStubs.token)
        )

        // Then
        testee.makeRequest(environment: environment) { _, _, error in
            expection.fulfill()
            XCTAssertEqual(error?.localizedDescription, DomainService.Issue.unableToGetToken.localizedDescription)
        }
        wait(for: [expection], timeout: 0.2)
    }
}
