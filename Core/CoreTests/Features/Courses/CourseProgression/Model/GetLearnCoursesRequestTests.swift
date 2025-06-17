//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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
import Foundation
import TestsFoundation
import XCTest

class GetLearnCoursesProgressionRequestTests: CoreTestCase {
    func testInputInit() {
        let input = GetHLearnCoursesProgressionRequest.Input(id: "user_123", horizonCourses: true)
        XCTAssertEqual(input.id, "user_123")
        XCTAssertTrue(input.horizonCourses)
    }

    func testRequestInit() {
        let request = GetHLearnCoursesProgressionRequest(userId: "user_123", horizonCourses: true)
        XCTAssertEqual(request.variables.id, "user_123")
        XCTAssertTrue(request.variables.horizonCourses)

        let defaultRequest = GetHLearnCoursesProgressionRequest(userId: "user_123")
        XCTAssertEqual(defaultRequest.variables.id, "user_123")
        XCTAssertTrue(defaultRequest.variables.horizonCourses)

        let falseRequest = GetHLearnCoursesProgressionRequest(userId: "user_123", horizonCourses: false)
        XCTAssertEqual(falseRequest.variables.id, "user_123")
        XCTAssertFalse(falseRequest.variables.horizonCourses)
    }

    func testOperationName() {
        XCTAssertEqual(GetHLearnCoursesProgressionRequest.operationName, "GetUserCourses")
    }

    func testQuery() {
        let expectedQuery = """
            query GetUserCourses($id: ID!, $horizonCourses: Boolean!) {
                legacyNode(_id: $id, type: User) {
                    ... on User {
                        enrollments(currentOnly: false, horizonCourses: $horizonCourses) {
                            id: _id
                            state
                            course {
                                id: _id
                                name
                            }
                        }
                    }
                }
            }
        """
        XCTAssertEqual(GetHLearnCoursesProgressionRequest.query, expectedQuery)
    }

    func testInputEquality() {
        let input1 = GetHLearnCoursesProgressionRequest.Input(id: "user_123", horizonCourses: true)
        let input2 = GetHLearnCoursesProgressionRequest.Input(id: "user_123", horizonCourses: true)
        let input3 = GetHLearnCoursesProgressionRequest.Input(id: "user_456", horizonCourses: true)
        let input4 = GetHLearnCoursesProgressionRequest.Input(id: "user_123", horizonCourses: false)

        XCTAssertEqual(input1, input2)
        XCTAssertNotEqual(input1, input3)
        XCTAssertNotEqual(input1, input4)
    }
}
