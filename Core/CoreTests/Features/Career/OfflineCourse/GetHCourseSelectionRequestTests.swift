//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

final class GetHCourseSelectionRequestTests: CoreTestCase {

    private static let userID = "user 1"

    // MARK: - Init

    func test_init_shouldSetVariablesFromUserID() {
        let request = GetHCourseSelectionRequest(userId: Self.userID)

        XCTAssertEqual(request.variables.id, Self.userID)
    }

    func test_init_withDefaultHorizonCourses_shouldBeTrue() {
        let request = GetHCourseSelectionRequest(userId: Self.userID)

        XCTAssertEqual(request.variables.horizonCourses, true)
    }

    func test_init_withExplicitHorizonCoursesFalse_shouldBeFalse() {
        let request = GetHCourseSelectionRequest(userId: Self.userID, horizonCourses: false)

        XCTAssertEqual(request.variables.horizonCourses, false)
    }

    func test_init_withNilHorizonCourses_shouldBeNil() {
        let request = GetHCourseSelectionRequest(userId: Self.userID, horizonCourses: nil)

        XCTAssertEqual(request.variables.horizonCourses, nil)
    }

    // MARK: - Operation name

    func test_operationName() {
        XCTAssertEqual(GetHCourseSelectionRequest.operationName, "GetCourseSelection")
    }

    // MARK: - Input Equatable

    func test_input_equality_whenSameValues_shouldBeEqual() {
        let input1 = GetHCourseSelectionRequest.Input(id: Self.userID, horizonCourses: true)
        let input2 = GetHCourseSelectionRequest.Input(id: Self.userID, horizonCourses: true)

        XCTAssertEqual(input1, input2)
    }

    func test_input_equality_whenDifferentID_shouldNotBeEqual() {
        let input1 = GetHCourseSelectionRequest.Input(id: "user 1", horizonCourses: true)
        let input2 = GetHCourseSelectionRequest.Input(id: "user 2", horizonCourses: true)

        XCTAssertNotEqual(input1, input2)
    }

    func test_input_equality_whenDifferentHorizonCourses_shouldNotBeEqual() {
        let input1 = GetHCourseSelectionRequest.Input(id: Self.userID, horizonCourses: true)
        let input2 = GetHCourseSelectionRequest.Input(id: Self.userID, horizonCourses: false)
        XCTAssertNotEqual(input1, input2)
    }

    func test_query() {
        let query =
            """
            query GetCourseSelection($id: ID!, $horizonCourses: Boolean) {
                legacyNode(_id: $id, type: User) {
                    ... on User {
                        enrollments(currentOnly: true, horizonCourses: $horizonCourses) {
                            _id
                            course {
                                _id
                                name
                                modulesConnection {
                                    edges {
                                        node {
                                            moduleItems {
                                                content {
                                                    ... on File {
                                                        _id
                                                        displayName
                                                        size
                                                        url
                                                        mimeClass
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            """

        XCTAssertEqual(GetHCourseSelectionRequest.query, query)
    }
}
