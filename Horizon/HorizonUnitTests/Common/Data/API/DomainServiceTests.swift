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
/*

import Combine
import Core
import Foundation
import Testing

@testable import Horizon

struct DomainServiceTests {

    // Given the Domain Service
    // When initilized with .cedar
    // When initialized with the baseURL https://example.com
    // When initialized with the us-east-1 region
    // Then the url is https://cedar-api-production.us-east-1.temp.prod.inseng.io
    @Test func when_initialized_with_east_1_region_then_url_is_correct() async throws {
        // Given
        let mockAPI = TestHooks.MockAPI()
        mockAPI.mockResult = ["token": "dGVzdF90b2tlbg=="]

        // When
        let domainService = DomainService(
            .cedar,
            baseURL: "https://example.com",
            region: "us-east-1",
            horizonApi: mockAPI
        )
        let api = try? await domainService.api().values.first { _ in true }

        // Then
        #expect(
            api?.baseURL.absoluteString == "https://cedar-api-production.us-east-1.temp.prod.inseng.io"
        )
    }
}

// Test helpers
enum TestHooks {
    class MockAPI: API {
        var mockResult: [String: String] = [:]
        var requestable: (any APIRequestable)?

        override func makeRequest<Request: APIRequestable>(
            _ requestable: Request,
            refreshToken: Bool = true,
            callback: @escaping (Request.Response?, URLResponse?, Error?) -> Void
        ) -> APITask? {
            self.requestable = requestable
            let task = MockTask()
            task.resume()
            let json = #"{"token": "SGVsbG8sIFJlZWQh"}"#.data(using: .utf8)!
            let decoded = try? JSONDecoder().decode(Request.Response.self, from: json)
            callback(decoded, nil, nil)
            return task
        }
    }
}

struct MockTask: APITask {
    var state: URLSessionTask.State = .completed
    var taskID: String?
    func cancel() {}
    func resume() {}
}
 */
