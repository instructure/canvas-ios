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
@testable import Core

class PactTests: XCTestCase {
    let service = PactVerificationService(url: "http://localhost", allowInsecureCertificates: true)
    lazy var provider = CanvasMockService(provider: "canvas-lms", consumer: "canvas-ios", pactVerificationService: service)
    lazy var environment: TestEnvironment = {
        let environment = TestEnvironment()
        environment.api = provider.api
        return environment
    }()

    func testGetCourseUsers() throws {
        let users = [APIUser.make()]
        let useCase = GetContextUsers(context: ContextModel(.course, id: "1"))
        try provider.uponReceiving(
            "List course users",
            with: useCase.request,
            respondWith: users
        )
        provider.run { testComplete in
            useCase.makeRequest(environment: self.environment) { response, _, _ in
                XCTAssertEqual(response, users)
                testComplete()
            }
        }
    }

    func testGetCourses() throws {
        let courses = [APICourse.make(start_at: Date.isoDateFromString("2020-01-23T00:00:00Z"))]
        let useCase = GetCourses()
        try provider.uponReceiving(
            "Get courses",
            with: useCase.request,
            respondWith: courses
        )
        provider.run { testComplete in
            useCase.makeRequest(environment: self.environment) { response, _, _ in
                XCTAssertEqual(response, courses)
                testComplete()
            }
        }
    }
}
