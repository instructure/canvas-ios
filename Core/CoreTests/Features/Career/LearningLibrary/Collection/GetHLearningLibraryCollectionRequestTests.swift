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

final class GetHLearningLibraryCollectionRequestTests: CoreTestCase {
    func testPath() {
        XCTAssertEqual(GetHLearningLibraryCollectionRequest().path, "/graphql")
    }

    func testHeader() {
        let request = GetHLearningLibraryCollectionRequest()
        XCTAssertEqual(request.headers.count, 1)
        XCTAssertEqual(request.headers.first?.key, "Accept")
        XCTAssertEqual(request.headers.first?.value, "application/json")
    }

    func testOperationName() {
        XCTAssertEqual(GetHLearningLibraryCollectionRequest.operationName, "GetEnrolledLearningLibraryCollections")
    }

    func testVariables() {
        let request = GetHLearningLibraryCollectionRequest()
        XCTAssertEqual(request.variables.itemLimitPerCollection, 4)
    }

    func testQuery() {
        let query = """
        query GetEnrolledLearningLibraryCollections($itemLimitPerCollection: Int!) {
          enrolledLearningLibraryCollections(
            input: {
              itemLimitPerCollection: $itemLimitPerCollection
            }
          ) {
            collections {
              id
              name
              publicName
              description
              createdAt
              updatedAt
              totalItemCount
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
        }
        """
        XCTAssertEqual(GetHLearningLibraryCollectionRequest.query, query)
    }
}
