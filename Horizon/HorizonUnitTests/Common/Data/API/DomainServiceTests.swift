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

import Combine
import Foundation
import XCTest

@testable import Core
@testable import Horizon

class DomainServiceTests: HorizonTestCase {

    func test_when_initialized_with_west_1_region_then_url_is_correct() async throws {
        // Given
        let baseURL = "https://example.com"
        let mockToken = "ZmFrZS1qd3QtdG9rZW4="
        api.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainJWTService.JWTTokenRequest.Result(token: mockToken)
        )

        // When
        let domainService = DomainService(
            .journey,
            baseURL: baseURL,
            region: "us-west-1",
            domainJWTService: DomainJWTService(horizonApi: api)
        )
        let domainServiceApi = try await domainService.api().values.first { _ in true }

        // Then
        XCTAssertEqual(
            domainServiceApi?.baseURL.absoluteString,
            "https://journey-server-prod.us-west-1.temp.prod.inseng.io",
            "The region should be included in the domain service URL"
        )
    }

    func test_when_initialized_with_east_1_region_then_url_is_correct() async throws {
        // Given
        let baseURL = "https://example.com"
        let mockToken = "ZmFrZS1qd3QtdG9rZW4="
        api.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainJWTService.JWTTokenRequest.Result(token: mockToken)
        )

        // When
        let domainService = DomainService(
            .journey,
            baseURL: baseURL,
            region: "us-east-1",
            domainJWTService: DomainJWTService(horizonApi: api)
        )
        let domainServiceApi = try await domainService.api().values.first { _ in true }

        // Then
        XCTAssertEqual(
            domainServiceApi?.baseURL.absoluteString,
            "https://journey-server-prod.us-east-1.temp.prod.inseng.io",
            "The region should be included in the domain service URL"
        )
    }

    func test_when_initialized_with_nonprod_baseURL_then_url_is_dev() async throws {
        // Given
        let baseURL = "https://horizon.cd.instructure.com"
        let mockToken = "ZmFrZS1qd3QtdG9rZW4="
        api.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainJWTService.JWTTokenRequest.Result(token: mockToken)
        )

        // When
        let domainService = DomainService(
            .journey,
            baseURL: baseURL,
            region: "us-east-1",
            domainJWTService: DomainJWTService(horizonApi: api)
        )
        let domainServiceApi = try await domainService.api().values.first { _ in true }

        // Then
        XCTAssertEqual(
            domainServiceApi?.baseURL.absoluteString,
            "https://journey-server-edge.journey.nonprod.inseng.io",
            "Non-prod environments should use dev URL"
        )
    }

    func test_when_journey_option_is_used_then_url_is_correct() async throws {
        // Given
        let baseURL = "https://example.com"
        let mockToken = "ZmFrZS1qd3QtdG9rZW4="
        api.mock(
            DomainJWTService.JWTTokenRequest(domainServiceOption: .journey),
            value: DomainJWTService.JWTTokenRequest.Result(token: mockToken)
        )

        // When
        let domainService = DomainService(
            .journey,
            baseURL: baseURL,
            region: "us-east-1",
            domainJWTService: DomainJWTService(horizonApi: api)
        )
        let domainServiceApi = try await domainService.api().values.first { _ in true }

        // Then
        XCTAssertEqual(
            domainServiceApi?.baseURL.absoluteString,
            "https://journey-server-prod.us-east-1.temp.prod.inseng.io",
            "Journey should use its specific URL pattern"
        )
    }
}
