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

final class GetHLearningLibraryItemRequestTests: CoreTestCase {
    func testPath() {
        XCTAssertEqual(GetHLearningLibraryItemRequest().path, "/graphql")
    }

    func testHeader() {
        let request = GetHLearningLibraryItemRequest()
        XCTAssertEqual(request.headers.count, 1)
        XCTAssertEqual(request.headers.first?.key, "Accept")
        XCTAssertEqual(request.headers.first?.value, "application/json")
    }

    func testOperationName() {
        XCTAssertEqual(GetHLearningLibraryItemRequest.operationName, "learningLibraryCollectionItems")
    }

    func testVariablesDefault() {
        let request = GetHLearningLibraryItemRequest()
        XCTAssertEqual(request.variables.limit, 100)
        XCTAssertNil(request.variables.cursor)
        XCTAssertTrue(request.variables.forward)
        XCTAssertFalse(request.variables.bookmarkedOnly)
        XCTAssertFalse(request.variables.completedOnly)
        XCTAssertNil(request.variables.searchTerm)
    }

    func testVariablesWithParameters() {
        let request = GetHLearningLibraryItemRequest(
            cursor: "test-cursor",
            bookmarkedOnly: true,
            completedOnly: true,
            searchTerm: "swift",
            types: ["COURSE", "PROGRAM"]
        )
        XCTAssertEqual(request.variables.cursor, "test-cursor")
        XCTAssertTrue(request.variables.bookmarkedOnly)
        XCTAssertTrue(request.variables.completedOnly)
        XCTAssertEqual(request.variables.searchTerm, "swift")
        XCTAssertEqual(request.variables.types, ["COURSE", "PROGRAM"])
    }

    func testQuery() {
        let name = "learningLibraryCollectionItems"
        let query = """
        query \(name)($limit: Int!, $cursor: String, $forward: Boolean!, $bookmarkedOnly: Boolean!, $completedOnly: Boolean!, $types: [CollectionItemType!], $searchTerm: String) {
          learningLibraryCollectionItems(
            input: {
              limit: $limit
              cursor: $cursor
              forward: $forward
              types: $types
              searchTerm: $searchTerm
              bookmarkedOnly: $bookmarkedOnly
              completedOnly: $completedOnly
            }
          ) {
            items {
         id
        libraryId
        itemType
        displayOrder
        isBookmarked
        completionPercentage
        isEnrolledInCanvas
        createdAt
        updatedAt
        canvasModuleId
        canvasModuleItemId
        canvasEnrollmentId
        canvasCourse {
          courseId
          courseName
          canvasUrl
          courseImageUrl
          moduleCount
          moduleItemCount
          estimatedDurationMinutes
        }
        programId
        programCourseId
        }
            pageInfo {
              nextCursor
              previousCursor
              hasNextPage
              hasPreviousPage
            }
          }
        }
        """
        XCTAssertEqual(GetHLearningLibraryItemRequest.query, query)
    }

    func testNextPageRequestWithHasNextPageTrue() {
        let response = GetHLearningLibraryItemResponse(
            data: .init(
                learningLibraryCollectionItems: .init(
                    items: [],
                    pageInfo: .init(
                        nextCursor: "next-cursor-123",
                        previousCursor: nil,
                        hasNextPage: true,
                        hasPreviousPage: false
                    )
                )
            )
        )
        let request = GetHLearningLibraryItemRequest()

        let nextRequest = request.nextPageRequest(from: response)

        XCTAssertNotNil(nextRequest)
        XCTAssertEqual(nextRequest?.variables.cursor, "next-cursor-123")
    }

    func testNextPageRequestWithHasNextPageFalse() {
        let response = GetHLearningLibraryItemResponse(
            data: .init(
                learningLibraryCollectionItems: .init(
                    items: [],
                    pageInfo: .init(
                        nextCursor: nil,
                        previousCursor: nil,
                        hasNextPage: false,
                        hasPreviousPage: false
                    )
                )
            )
        )
        let request = GetHLearningLibraryItemRequest()

        let nextRequest = request.nextPageRequest(from: response)

        XCTAssertNil(nextRequest)
    }

    func testNextPageRequestWithNilData() {
        let response = GetHLearningLibraryItemResponse(data: nil)
        let request = GetHLearningLibraryItemRequest()

        let nextRequest = request.nextPageRequest(from: response)

        XCTAssertNil(nextRequest)
    }
}
