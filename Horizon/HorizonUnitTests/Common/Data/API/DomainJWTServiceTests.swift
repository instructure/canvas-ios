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
import Combine
import CombineSchedulers
@testable import Core
@testable import Horizon

final class DomainJWTServiceTests: HorizonTestCase {
    var service: DomainJWTService!
    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        super.setUp()
        service = DomainJWTService(horizonApi: api)
    }

    override func tearDown() {
        subscriptions.removeAll()
        super.tearDown()
    }

    // MARK: - Token Request Tests

    func testGetTokenSuccessReturnsParsedToken() {
        // Given
        let expectation = expectation(description: "Token request completes")
        let mockToken = "ZmFrZS1qd3QtdG9rZW4="
        api.mock(DomainJWTService.JWTTokenRequest(domainServiceOption: .cedar),
                 value: .make(token: mockToken))

        // When
        var receivedToken: String?
        service.getValidToken(option: .cedar)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Expected success but got error: \(error)")
                    }
                    expectation.fulfill()
                },
                receiveValue: { token in
                    receivedToken = token
                }
            )
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 0.5)

        // Then
        XCTAssertEqual(receivedToken, "fake-jwt-token")
    }

    func testGetTokenEmptyTokenThrowsError() {
        // Given
        let expectation = expectation(description: "Token request completes")
        api.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .cedar),
            value: .make(token: "")
        )

        // When
        var receivedError: Error?
        service.getValidToken(option: .cedar)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    } else {
                        XCTFail("Expected failure but received success")
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 0.5)

        // Then
        guard let error = receivedError else {
            return XCTFail("Expected an error but got nil")
        }

        XCTAssertTrue(error is DomainJWTService.Issue, "Expected DomainJWTService.Issue but got \(type(of: error))")
        XCTAssertEqual(error as? DomainJWTService.Issue, .unableToGetToken)
    }

    // MARK: - Caching Tests

    func testGetToken_CachesValidToken() async throws {
        // Given
        let mockToken = "ZmFrZS1qd3QtdG9rZW4="
        api.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .cedar),
            value: .make(token: mockToken)
        )

        // When — first request (fetches from network and caches)
        _ = try await service.getValidToken(option: .cedar)
            .values
            .first(where: { _ in true }) // Get first emitted value

        // Then — second request (should use cache)
        var secondToken: String?
        secondToken = try await service.getValidToken(option: .cedar)
            .values
            .first(where: { _ in true })

        // Then
        XCTAssertEqual(secondToken, "fake-jwt-token")
    }
}

private extension DomainJWTService.JWTTokenRequest.Result {
    static func make(token: String) -> Self {
        return .init(token: token)
    }
}
