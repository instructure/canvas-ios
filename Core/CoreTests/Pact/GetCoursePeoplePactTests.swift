//
// This file is part of Canvas.

// Copyright (C) 2020-present  Instructure, Inc.
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

import Foundation
import TestsFoundation
import PactConsumerSwift
import Core

class PactCoursePeopleTests: XCTestCase {
    let environment = TestEnvironment()

    func testPactThing() {
        let service = PactVerificationService(url: "http://localhost", allowInsecureCertificates: true)
        let provider = MockService(provider: "foo", consumer: "bar", pactVerificationService: service)
        environment.api = URLSessionAPI(baseURL: URL(string: provider.baseUrl)!)

        let users: [APIUser] = [.make()]
        let useCase = GetContextUsers(context: ContextModel(.course, id: "1"))
        let url = try! useCase.request.urlRequest(relativeTo: environment.api.baseURL, accessToken: "t", actAsUserID: nil).url!
        provider
            .uponReceiving("a request for hello")
            .withRequest(method: .GET, path: url.path, query: url.query)
            .willRespondWith(status: 200, body: String(data: try! JSONEncoder().encode(users), encoding: .utf8))
        provider.run { testComplete in
            useCase.makeRequest(environment: self.environment) { response, _, _ in
                XCTAssertEqual(response, users)
                testComplete()
            }
        }
    }
}
