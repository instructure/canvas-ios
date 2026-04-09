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

final class LearningLibraryBookMarkRequestTests: CoreTestCase {
    func testPath() {
        XCTAssertEqual(LearningLibraryBookMarkRequest(id: "test-id").path, "/graphql")
    }

    func testHeader() {
        let request = LearningLibraryBookMarkRequest(id: "test-id")
        XCTAssertEqual(request.headers.count, 1)
        XCTAssertEqual(request.headers.first?.key, "Accept")
        XCTAssertEqual(request.headers.first?.value, "application/json")
    }

    func testOperationName() {
        XCTAssertEqual(LearningLibraryBookMarkRequest.operationName, "ToggleCollectionItemBookmark")
    }

    func testVariables() {
        let request = LearningLibraryBookMarkRequest(id: "item-123")
        XCTAssertEqual(request.variables.input.collectionItemId, "item-123")
    }

    func testQuery() {
        let query = """
        mutation ToggleCollectionItemBookmark($input: ToggleCollectionItemBookmarkInput!) {
          toggleCollectionItemBookmark(input: $input) {
            isBookmarked
          }
        }
        """
        XCTAssertEqual(LearningLibraryBookMarkRequest.query, query)
    }
}
