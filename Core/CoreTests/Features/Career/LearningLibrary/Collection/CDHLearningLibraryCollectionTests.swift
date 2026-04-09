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

final class CDHLearningLibraryCollectionTests: CoreTestCase {
    func testSave() {
        let apiEntity = LearningLibraryStubs.collection

        let savedEntity = CDHLearningLibraryCollection.save(apiEntity, in: databaseClient)

        XCTAssertEqual(savedEntity.id, LearningLibraryStubs.collection.id)
        XCTAssertEqual(savedEntity.name, LearningLibraryStubs.collection.name)
        XCTAssertEqual(savedEntity.totalItemCount, String(LearningLibraryStubs.collection.totalItemCount ?? 0))
        XCTAssertEqual(savedEntity.items.count, 1)
    }

    func testSaveWithNilValues() {
        let apiEntity = LearningLibraryStubs.collectionWithNilValues

        let savedEntity = CDHLearningLibraryCollection.save(apiEntity, in: databaseClient)

        XCTAssertEqual(savedEntity.id, LearningLibraryStubs.collectionWithNilValues.id)
        XCTAssertEqual(savedEntity.name, LearningLibraryStubs.collectionWithNilValues.name)
        XCTAssertEqual(savedEntity.totalItemCount, "0")
        XCTAssertEqual(savedEntity.items.count, 0)
    }
}
