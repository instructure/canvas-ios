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
            .first(where: { _ in true })

        // Then — second request (should use cache)
        var secondToken: String?
        secondToken = try await service.getValidToken(option: .cedar)
            .values
            .first(where: { _ in true })

        // Then
        XCTAssertEqual(secondToken, "fake-jwt-token")
    }

    func testGetToken_DifferentOptionsAreCachedSeparately() async throws {
        // Given
        let cedarToken = "Y2VkYXItdG9rZW4="
        let pineToken = "cGluZS10b2tlbg=="

        api.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .cedar),
            value: .make(token: cedarToken)
        )
        api.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .pine),
            value: .make(token: pineToken)
        )

        // When
        let cedarResult = try await service.getValidToken(option: .cedar)
            .values
            .first(where: { _ in true })
        let pineResult = try await service.getValidToken(option: .pine)
            .values
            .first(where: { _ in true })

        // Then
        XCTAssertEqual(cedarResult, "cedar-token")
        XCTAssertEqual(pineResult, "pine-token")
    }

    func testGetToken_InvalidBase64ThrowsError() {
        // Given
        let expectation = expectation(description: "Token request completes")
        api.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .cedar),
            value: .make(token: "not-valid-base64!!!")
        )

        // When
        var receivedError: Error?
        service.getValidToken(option: .cedar)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        receivedError = error
                    }
                    expectation.fulfill()
                },
                receiveValue: { _ in }
            )
            .store(in: &subscriptions)

        wait(for: [expectation], timeout: 0.5)

        // Then
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError as? DomainJWTService.Issue, .unableToGetToken)
    }

    func testClear_RemovesAllCachedTokens() async throws {
        // Given
        let mockToken = "ZmFrZS1qd3QtdG9rZW4="
        let mockToken2 = "bmV3LWZha2UtdG9rZW4="

        api.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .cedar),
            value: .make(token: mockToken)
        )

        let firstToken = try await service.getValidToken(option: .cedar).values.first(where: { _ in true })
        XCTAssertEqual(firstToken, "fake-jwt-token")

        // When
        service.clear()

        // Allow async clear to complete
        try await Task.sleep(nanoseconds: 100_000_000)

        // Mock a different token to verify new request is made
        api.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .cedar),
            value: .make(token: mockToken2)
        )

        // Then — should fetch new token, not use cache
        let newToken = try await service.getValidToken(option: .cedar).values.first(where: { _ in true })
        XCTAssertEqual(newToken, "new-fake-token")
    }

    func testSetAPIAfterLogin_UsesNewAPI() async throws {
        // Given
        let originalToken = "b3JpZ2luYWwtdG9rZW4="
        let newToken = "bmV3LWFwaS10b2tlbg=="
        let url = URL(string: "https://career.com")!

        api.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .cedar),
            value: .make(token: originalToken)
        )

        let firstToken = try await service.getValidToken(option: .cedar).values.first(where: { _ in true })
        XCTAssertEqual(firstToken, "original-token")

        // When
        let loginSession = LoginSession(
            accessToken: "jwt",
            baseURL: url,
            userID: "",
            userName: ""
        )
        let newApi = API(loginSession, baseURL: url)
        newApi.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .cedar),
            value: .make(token: newToken)
        )

        service.setAPIAfterLogin(newApi)
        service.clear()

        // Then
        let tokenAfterAPIChange = try await service.getValidToken(option: .cedar).values.first(where: { _ in true })
        XCTAssertEqual(tokenAfterAPIChange, "new-api-token")
    }
}

private extension DomainJWTService.JWTTokenRequest.Result {
    static func make(token: String) -> Self {
        return .init(token: token)
    }
}
