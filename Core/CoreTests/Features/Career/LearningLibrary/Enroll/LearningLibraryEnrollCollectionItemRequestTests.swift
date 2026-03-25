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

final class LearningLibraryEnrollCollectionItemRequestTests: CoreTestCase {
    func testPath() {
        XCTAssertEqual(LearningLibraryEnrollCollectionItemRequest(id: "test-id").path, "/graphql")
    }

    func testHeader() {
        let request = LearningLibraryEnrollCollectionItemRequest(id: "test-id")
        XCTAssertEqual(request.headers.count, 1)
        XCTAssertEqual(request.headers.first?.key, "Accept")
        XCTAssertEqual(request.headers.first?.value, "application/json")
    }

    func testOperationName() {
        XCTAssertEqual(LearningLibraryEnrollCollectionItemRequest.operationName, "EnrollLearnerInCollectionItem")
    }

    func testVariables() {
        let request = LearningLibraryEnrollCollectionItemRequest(id: "item-123")
        XCTAssertEqual(request.variables.input.collectionItemId, "item-123")
    }

    func testQuery() {
        let query = """
        mutation EnrollLearnerInCollectionItem($input: EnrollLearnerInCollectionItemInput!) {
           enrollLearnerInCollectionItem(input: $input) {
            wasAlreadyEnrolled
           item {
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
        XCTAssertEqual(LearningLibraryEnrollCollectionItemRequest.query, query)
    }
}
