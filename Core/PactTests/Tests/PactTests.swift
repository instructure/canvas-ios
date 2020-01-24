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
        let user = APIUser.make(locale: nil, permissions: nil)
        let useCase = GetContextUsers(context: ContextModel(.course, id: "868"))
        try provider.uponReceiving(
            "List course users",
            with: useCase.request,
            respondWithArrayLike: user
        )
        provider.run { testComplete in
            useCase.makeRequest(environment: self.environment) { response, _, _ in
                XCTAssertEqual(response, [user])
                testComplete()
            }
        }
    }

    func testGetCourses() throws {
        let course = APICourse.make(
            start_at: Date.isoDateFromString("2020-01-23T00:00:00Z"),
            enrollments: [
                .make(
                    id: nil,
                    enrollment_state: .active,
                    user_id: "12",
                    role: "StudentEnrollment",
                    role_id: "3",
                    current_grading_period_id: nil,
                    user: nil
                ),
        ])
        let useCase = GetCourses()
        try provider.uponReceiving(
            "Get courses",
            with: useCase.request,
            respondWithArrayLike: course
        )
        provider.run { testComplete in
            useCase.makeRequest(environment: self.environment) { response, _, _ in
                XCTAssertEqual(response, [course])
                testComplete()
            }
        }
    }
}
