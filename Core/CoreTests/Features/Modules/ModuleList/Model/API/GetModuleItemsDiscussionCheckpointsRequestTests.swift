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

import XCTest
@testable import Core

final class GetModuleItemsDiscussionCheckpointsRequestTests: XCTestCase {

    private static let testData = (
        courseId: "some courseId",
        pageSize: 42,
        cursor: "some cursor"
    )
    private lazy var testData = Self.testData

    private var testee: GetModuleItemsDiscussionCheckpointsRequest!

    override func setUp() {
        super.setUp()
        testee = GetModuleItemsDiscussionCheckpointsRequest(courseId: testData.courseId)
    }

    override func tearDown() {
        testee = nil
        super.tearDown()
    }

    // MARK: - Variables - Default values

    func test_init_withDefaultParameters_shouldSetCorrectValues() {
        testee = .init(courseId: testData.courseId)

        XCTAssertEqual(testee.variables.courseId, testData.courseId)
        XCTAssertEqual(testee.variables.pageSize, 20)
        XCTAssertEqual(testee.variables.cursor, nil)
    }

    // MARK: - Request Body

    func test_body() {
        testee = .init(
            courseId: testData.courseId,
            pageSize: testData.pageSize,
            cursor: testData.cursor
        )

        testee.assertBodyEquals(
            GraphQLBody(
                query: GetModuleItemsDiscussionCheckpointsRequest.query,
                operationName: "GetModuleItemsDiscussionCheckpointsRequest",
                variables: .init(
                    courseId: testData.courseId,
                    pageSize: testData.pageSize,
                    cursor: testData.cursor
                )
            )
        )
    }

    // MARK: - nextPageRequest

    func test_nextPageRequest_whenResponseHasNextPage_shouldReturnNewRequest() {
        testee = .init(
            courseId: testData.courseId,
            pageSize: testData.pageSize
        )

        let nextRequest = testee.nextPageRequest(
            from: .make(pageInfo: APIPageInfo(endCursor: testData.cursor, hasNextPage: true))
        )

        XCTAssertEqual(nextRequest?.variables.courseId, testData.courseId)
        XCTAssertEqual(nextRequest?.variables.pageSize, testData.pageSize)
        XCTAssertEqual(nextRequest?.variables.cursor, testData.cursor)
    }

    func test_nextPageRequest_whenResponseHasPageInfo_shouldReturnNil() {
        testee = .init(courseId: testData.courseId)

        let nextRequest = testee.nextPageRequest(
            from: .make(pageInfo: nil)
        )

        XCTAssertNil(nextRequest)
    }

    func test_nextPageRequest_whenResponseHasNoNextPage_shouldReturnNil() {
        testee = .init(courseId: testData.courseId)

        let nextRequest = testee.nextPageRequest(
            from: .make(pageInfo: APIPageInfo(endCursor: testData.cursor, hasNextPage: false))
        )

        XCTAssertNil(nextRequest)
    }
}
