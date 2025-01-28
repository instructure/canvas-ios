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

import Foundation
import XCTest
@testable import Core

class AssignmentPickerListRequestTests: CoreTestCase {

    func testRequest() {
        let operationName = "AssignmentPickerList"
        let query = """
        query \(operationName)($courseID: ID!, $pageSize: Int!, $cursor: String) {
          course(id: $courseID) {
            assignmentsConnection(filter: { gradingPeriodId: null }, first: $pageSize, after: $cursor) {
              nodes {
                name
                _id
                allowedExtensions
                submissionTypes
                gradeAsGroup
                lockInfo {
                  isLocked
                }
              }
              pageInfo {
                endCursor
                hasNextPage
              }
            }
          }
        }
        """

        let request = AssignmentPickerListRequest(courseID: "_course_id_")

        XCTAssertEqual(request.body?.query, query)
        XCTAssertEqual(request.variables.courseID, "_course_id_")
        XCTAssertEqual(request.variables.pageSize, 20)
        XCTAssertNil(request.variables.cursor)
    }

    func testResponse() {
        let mockedResponse = makeResponse(pageInfo: nil)
        let request = AssignmentPickerListRequest(courseID: "_course_id_")

        api.mock(request, value: mockedResponse)
        api.makeRequest(request) { response, _, _  in
            XCTAssertEqual(response?.data, mockedResponse.data)
            XCTAssertEqual(response?.assignments[0]._id, "A1")
            XCTAssertEqual(response?.assignments[0].name, "Assignment 1")
            XCTAssertEqual(response?.assignments[1]._id, "A2")
            XCTAssertEqual(response?.assignments[1].name, "Assignment 2")
        }
    }

    func test_next_page() throws {
        let response = makeResponse(
            pageInfo: APIPageInfo(endCursor: "next_cursor", hasNextPage: true)
        )

        let nextRequest = try XCTUnwrap(
            AssignmentPickerListRequest(courseID: "_course_id_").nextPageRequest(from: response)
        )

        XCTAssertEqual(nextRequest.variables.cursor, "next_cursor")
    }

    func test_no_next_page() throws {
        // Case 1
        var response = makeResponse(
            pageInfo: APIPageInfo(endCursor: "next_cursor", hasNextPage: false)
        )
        var nextRequest = AssignmentPickerListRequest(courseID: "_course_id_")
            .nextPageRequest(from: response)
        XCTAssertNil(nextRequest)

        // Case 2
        response = makeResponse(pageInfo: nil)
        nextRequest = AssignmentPickerListRequest(courseID: "_course_id_")
            .nextPageRequest(from: response)
        XCTAssertNil(nextRequest)
    }

    private func makeResponse(pageInfo: APIPageInfo?) -> AssignmentPickerListResponse {
        return AssignmentPickerListResponse(
            data: .init(
                course: .init(
                    assignmentsConnection: .init(
                        nodes: [
                            .make(id: "A1", name: "Assignment 1", submission_types: [.online_upload]),
                            .make(id: "A2", name: "Assignment 2", submission_types: [.online_upload]),

                        ],
                        pageInfo: pageInfo
                    )
                )
            )
        )
    }
}
