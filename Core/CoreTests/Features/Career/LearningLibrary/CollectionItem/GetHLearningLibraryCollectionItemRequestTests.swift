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

final class GetHLearningLibraryCollectionItemRequestTests: CoreTestCase {
    func testPath() {
        XCTAssertEqual(GetHLearningLibraryCollectionItemRequest(id: "test-id").path, "/graphql")
    }

    func testHeader() {
        let request = GetHLearningLibraryCollectionItemRequest(id: "test-id")
        XCTAssertEqual(request.headers.count, 1)
        XCTAssertEqual(request.headers.first?.key, "Accept")
        XCTAssertEqual(request.headers.first?.value, "application/json")
    }

    func testOperationName() {
        XCTAssertEqual(GetHLearningLibraryCollectionItemRequest.operationName, "GetEnrolledLearningLibraryCollection")
    }

    func testVariables() {
        let request = GetHLearningLibraryCollectionItemRequest(id: "collection-123")
        XCTAssertEqual(request.variables.id, "collection-123")
    }

    func testQuery() {
        let query = """
        query GetEnrolledLearningLibraryCollection($id: String!) {
          enrolledLearningLibraryCollection(id: $id) {
            id
            name
            publicName
            description
            createdAt
            updatedAt
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
          }
        }
        """
        XCTAssertEqual(GetHLearningLibraryCollectionItemRequest.query, query)
    }
}
