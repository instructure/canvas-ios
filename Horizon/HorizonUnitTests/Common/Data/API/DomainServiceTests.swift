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

    // Given the Domain Service
    // When initilized with .cedar
    // When initialized with the baseURL https://example.com
    // When initialized with the us-east-1 region
    // Then the url is https://cedar-api-production.us-east-1.temp.prod.inseng.io
    func test_when_initialized_with_east_1_region_then_url_is_correct() async throws {
        // Given
        let baseURL = "https://example.com"
        let requestKey = "POST:https://canvas.instructure.com/api/v1/jwts?canvas_audience=false&no_verifiers=1&workflows%5B%5D=cedar"
        let response = DomainJWTService.JWTTokenRequest.Result(token: "ZmFrZS1qd3QtdG9rZW4=")
        let responseData = try! JSONEncoder().encode(response)
        let apiMock = APIMock { _ in
            (responseData, nil, nil)
        }
        API.mocks = [requestKey: apiMock]

        // When
        let domainService = DomainService(
            .cedar,
            baseURL: baseURL,
            region: "us-west-1",
            domainJWTService: DomainJWTService(horizonApi: api)
        )
        let domainServiceApi = try? await domainService.api().values.first { _ in true }

        // Then
        XCTAssertEqual(
            domainServiceApi!.baseURL.absoluteString,
            "https://cedar-api-production.us-west-1.temp.prod.inseng.io",
            "The region should be included in the domain service URL"
        )
    }
}
