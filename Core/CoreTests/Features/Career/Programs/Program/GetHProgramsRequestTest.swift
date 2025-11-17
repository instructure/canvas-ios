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

@testable import Core
import XCTest

final class GetHProgramsRequestTest: CoreTestCase {
    func testPath() {
        XCTAssertEqual(GetHProgramsRequest().path, "/graphql")
    }

    func testHeader() {
        let request = GetHProgramsRequest()
        XCTAssertEqual(request.headers.count, 1)
        XCTAssertEqual(request.headers.first?.key, "Accept")
        XCTAssertEqual(request.headers.first?.value, "application/json")
    }

    func testShouldAddNoVerifierQuery() {
        let request = GetHProgramsRequest()
        XCTAssertFalse(request.shouldAddNoVerifierQuery)
    }

    func testOperationName() {
        XCTAssertEqual(GetHProgramsRequest.operationName, "EnrolledPrograms")
    }

    func testQuery() {
         let query = """
            query EnrolledPrograms {
              enrolledPrograms {
                id
                name
                publicName
                customerId
                description
                owner
                startDate
                endDate
                variant
                courseCompletionCount
                progresses {
                  id
                  completionPercentage
                  courseEnrollmentStatus
                  requirement {
                    id
                    dependent {
                      id
                      canvasCourseId
                      canvasUrl
                    }
                  }
                }
                requirements {
                  id
                  isCompletionRequired
                  courseEnrollment
                  dependency {
                    id
                    canvasCourseId
                    canvasUrl
                  }
                  dependent {
                    id
                    canvasCourseId
                    canvasUrl
                  }
                }
                enrollments {
                  id
                  enrollee
                }
              }
            }
            """
        XCTAssertEqual(GetHProgramsRequest.query, query)
    }
}
