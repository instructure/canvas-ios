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

class CoursePactTests: PactTestCase {
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
        ).given("a student with 2 courses")
        provider.run { testComplete in
            useCase.makeRequest(environment: self.environment) { response, _, _ in
                XCTAssertEqual(response, [course])
                testComplete()
            }
        }
    }
}
