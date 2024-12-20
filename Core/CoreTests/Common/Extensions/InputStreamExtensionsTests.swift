//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

import Core
import XCTest

class InputStreamExtensionsTests: XCTestCase {

    func testCopyWithContentSmallerThanBuffer() {
        copyStreamToFile(streamSize: 10, bufferSize: 15)
    }

    func testCopyWithContentSizeEqualBuffer() {
        copyStreamToFile(streamSize: 10, bufferSize: 10)
    }

    func testCopyWithContentBiggerThanBuffer() {
        copyStreamToFile(streamSize: 13, bufferSize: 10)
    }

    private func copyStreamToFile(streamSize: Int, bufferSize: Int) {
        // Create temp file to where stream content will be written
        let targetFilePath = URL.Directories.temporary.appendingPathComponent(UUID.string)
        guard FileManager.default.createFile(atPath: targetFilePath.path, contents: nil) else {
            XCTFail("Failed to create temp file.")
            return
        }
        defer { try? FileManager.default.removeItem(at: targetFilePath) }
        guard let outputStream = OutputStream(toFileAtPath: targetFilePath.path, append: false) else {
            XCTFail("Failed to open stream to temp file.")
            return
        }
        outputStream.open()
        defer { outputStream.close() }

        // Create test data and setup a stream to read it
        let testData = Data(repeating: 6, count: streamSize)
        let testDataStream = InputStream(data: testData)
        testDataStream.open()
        defer { testDataStream.close() }

        // Copy stream content to file
        try! testDataStream.copy(to: outputStream, bufferSize: bufferSize)

        // Read back written data to be compared with original data
        guard let resultData = try? Data(contentsOf: targetFilePath) else {
            XCTFail("Failed to read temp file.")
            return
        }

        XCTAssertEqual(resultData, testData)
    }
}
