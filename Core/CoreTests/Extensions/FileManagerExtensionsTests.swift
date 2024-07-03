//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Combine
@testable import Core
import TestsFoundation
import XCTest

class FileManagerExtensionsTests: CoreTestCase {
    private let fileManager = FileManager.default
    private let directory = URL.Directories.temporary.appendingPathComponent(
        "FileManagerExtensionsTests",
        isDirectory: true
    )

    override func setUpWithError() throws {
        try super.setUpWithError()
        try fileManager.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )
    }

    override func tearDownWithError() throws {
        try fileManager.removeItem(at: directory)
        try super.tearDownWithError()
    }

    func testRemoveItemPublisher() {
        let fileURL = directory.appendingPathComponent("test.txt")
        fileManager.createFile(
            atPath: fileURL.path,
            contents: "test".data(using: .utf8)
        )

        XCTAssertTrue(fileManager.fileExists(atPath: fileURL.path))
        XCTAssertFinish(fileManager.removeItemPublisher(at: fileURL))
        XCTAssertFalse(fileManager.fileExists(atPath: fileURL.path))
    }

    func testListsAllFilesInDirectory() throws {
        let subdirectory = directory
            .appendingPathComponent("subfolder", isDirectory: true)
        try fileManager.createDirectory(
            at: subdirectory,
            withIntermediateDirectories: true
        )

        let subDirectoryWithTxtExtension = directory
            .appendingPathComponent("subfolder.txt", isDirectory: true)
        try fileManager.createDirectory(
            at: subDirectoryWithTxtExtension,
            withIntermediateDirectories: true
        )

        let file1URL = directory.appendingPathComponent("file1.txt")
        fileManager.createFile(
            atPath: file1URL.path,
            contents: "test".data(using: .utf8)
        )

        let file2URL = subdirectory.appendingPathComponent("file2.txt")
        fileManager.createFile(
            atPath: file2URL.path,
            contents: "test".data(using: .utf8)
        )

        let file3URL = subdirectory.appendingPathComponent("file3.html")
        fileManager.createFile(
            atPath: file3URL.path,
            contents: "test".data(using: .utf8)
        )

        // file1.txt
        // |- subfolder
        //    |- file2.txt
        //    |- file3.html
        // |- subfolder.txt

        XCTAssertEqual(
            fileManager.allFiles(withExtension: "txt", inDirectory: directory),
            Set([file1URL, file2URL])
        )
        XCTAssertEqual(
            fileManager.allFiles(withExtension: ".html", inDirectory: directory),
            Set([file3URL])
        )
    }
}
