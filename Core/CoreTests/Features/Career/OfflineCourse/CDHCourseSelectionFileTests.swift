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

final class CDHCourseSelectionFileTests: CoreTestCase {

    private static let testData = (
        courseID: "course 1",
        fileID: "file 1",
        displayName: "file name 1",
        size: "2 MB",
        url: URL(string: "https://example.com/file1")
    )
    private lazy var testData = Self.testData

    // MARK: - Save

    func test_save_shouldPersistAllProperties() {
        let content = makeContent(
            id: testData.fileID,
            displayName: testData.displayName,
            size: testData.size,
            url: testData.url
        )

        let result = CDHCourseSelectionFile.save(
            courseID: testData.courseID,
            file: content,
            in: databaseClient
        )

        XCTAssertEqual(result.courseID, testData.courseID)
        XCTAssertEqual(result.id, testData.fileID)
        XCTAssertEqual(result.name, testData.displayName)
        XCTAssertEqual(result.size, testData.size)
        XCTAssertEqual(result.url, testData.url)
    }

    func test_save_whenCalledTwiceWithSameIDs_shouldUpdateExistingRecord() {
        let content = makeContent(id: testData.fileID, displayName: "old name", size: "1 MB")

        CDHCourseSelectionFile.save(courseID: testData.courseID, file: content, in: databaseClient)

        let updatedContent = makeContent(id: testData.fileID, displayName: "new name", size: "3 MB")
        CDHCourseSelectionFile.save(courseID: testData.courseID, file: updatedContent, in: databaseClient)

        let files: [CDHCourseSelectionFile] = databaseClient.fetch()
        XCTAssertEqual(files.count, 1)
        XCTAssertEqual(files.first?.name, "new name")
        XCTAssertEqual(files.first?.size, "3 MB")
    }

    func test_save_whenFileIDIsNil_shouldUseEmptyString() {
        let content = makeContent(id: nil, displayName: "some name", size: "1 MB")

        let result = CDHCourseSelectionFile.save(
            courseID: testData.courseID,
            file: content,
            in: databaseClient
        )

        XCTAssertEqual(result.id, "")
    }

    func test_save_whenDisplayNameIsNil_shouldUseEmptyString() {
        let content = makeContent(id: testData.fileID, displayName: nil, size: "1 MB")

        let result = CDHCourseSelectionFile.save(
            courseID: testData.courseID,
            file: content,
            in: databaseClient
        )

        XCTAssertEqual(result.name, "")
    }

    func test_save_whenSizeIsNil_shouldUseEmptyString() {
        let content = makeContent(id: testData.fileID, displayName: "some name", size: nil)

        let result = CDHCourseSelectionFile.save(
            courseID: testData.courseID,
            file: content,
            in: databaseClient
        )

        XCTAssertEqual(result.size, "")
    }

    func test_save_whenURLIsNil_shouldPersistNilURL() {
        let content = makeContent(id: testData.fileID, displayName: "some name", size: "1 MB", url: nil)

        let result = CDHCourseSelectionFile.save(
            courseID: testData.courseID,
            file: content,
            in: databaseClient
        )

        XCTAssertEqual(result.url, nil)
    }

    // MARK: - Private helpers

    private func makeContent(
        id: String?,
        displayName: String?,
        size: String?,
        url: URL? = nil
    ) -> GetHCourseSelectionResponse.Content {
        GetHCourseSelectionResponse.Content(
            id: id,
            displayName: displayName,
            size: size,
            url: url,
            mimeClass: "pdf",
            updatedAt: nil
        )
    }
}
