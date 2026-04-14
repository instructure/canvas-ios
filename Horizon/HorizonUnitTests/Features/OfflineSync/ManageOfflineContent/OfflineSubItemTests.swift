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
@testable import Horizon
import XCTest

final class OfflineSubItemTests: HorizonTestCase {

    private static let testData = (
        fileID: "file 1",
        courseID: "course 1",
        fileName: "file name 1",
        fileSize: "2 MB",
        fileSizeInBytes: Double(2_000_000),
        fileURL: URL(string: "https://example.com/file.pdf")
    )
    private lazy var testData = Self.testData

    // MARK: - init(from entity)

    func test_initFromEntity_shouldMapAllProperties() {
        let entity: CDHCourseSelectionFile = databaseClient.insert()
        entity.id = testData.fileID
        entity.courseID = testData.courseID
        entity.name = testData.fileName
        entity.size = testData.fileSize
        entity.sizeInBytes = testData.fileSizeInBytes
        entity.url = testData.fileURL

        let testee = OfflineFileItem(from: entity)

        XCTAssertEqual(testee.id, testData.fileID)
        XCTAssertEqual(testee.name, testData.fileName)
        XCTAssertEqual(testee.size, testData.fileSize)
        XCTAssertEqual(testee.sizeInBytes, testData.fileSizeInBytes)
        XCTAssertEqual(testee.url, testData.fileURL)
    }

    func test_initFromEntity_shouldDefaultIsSelectedToFalse() {
        let entity: CDHCourseSelectionFile = databaseClient.insert()
        entity.id = testData.fileID
        entity.courseID = testData.courseID
        entity.name = testData.fileName
        entity.size = testData.fileSize
        entity.sizeInBytes = testData.fileSizeInBytes

        let testee = OfflineFileItem(from: entity)

        XCTAssertEqual(testee.isSelected, false)
    }

    func test_initFromEntity_whenURLIsNil_shouldMapURLAsNil() {
        let entity: CDHCourseSelectionFile = databaseClient.insert()
        entity.id = testData.fileID
        entity.courseID = testData.courseID
        entity.name = testData.fileName
        entity.size = testData.fileSize
        entity.sizeInBytes = testData.fileSizeInBytes
        entity.url = nil

        let testee = OfflineFileItem(from: entity)

        XCTAssertEqual(testee.url, nil)
    }
}
