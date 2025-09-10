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

final class GetHProgramCoursRequestTests: XCTestCase {

    func testOperationName() {
        XCTAssertEqual(GetHProgramCourseRequest.operationName, "GetProgramCourse")
    }

    func testVariables() {
        let request = GetHProgramCourseRequest(courseIDs: ["1", "2", "3"])
        XCTAssertEqual(request.variables.ids, ["1", "2", "3"])
    }

    func testQuery() {
        let query: String = """
            query GetProgramCourse($ids: [ID!]) {
              courses(ids: $ids) {
                _id
                name
                modulesConnection {
                  edges {
                    node {
                      id
                      name
                      moduleItems {
                        published
                        _id
                        estimatedDuration
                      }
                    }
                  }
                }
              }
            }
    """
        XCTAssertEqual(GetHProgramCourseRequest.query, query)
    }
}
