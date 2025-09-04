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

final class GetHCoursesEnrollmentIDRequestTests: CoreTestCase {
    func testOperationName() {
        XCTAssertEqual(GetHCoursesEnrollmentIDRequest.operationName, "GetCoursesEnrollmentIDs")
    }

    func testVariables() {
        let testee = GetHCoursesEnrollmentIDRequest(userId: "1234")
        XCTAssertEqual(testee.variables.id, "1234")
    }

    func testQuery() {
        let query = """
            query GetCoursesEnrollmentIDs($id: ID!) {
         legacyNode(_id: $id, type: User) {
           ... on User {
            enrollments(currentOnly: false) {
              _id
              course {
                _id
              }
            }
          }
          }
        }
        """
        XCTAssertEqual(GetHCoursesEnrollmentIDRequest.query, query)
    }
}
