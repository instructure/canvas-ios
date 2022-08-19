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

import XCTest
import Core

class FileSubmissionTests: CoreTestCase {

    func testSubmittedState() {
        let testee: FileSubmission = databaseClient.insert()
        testee.isSubmitted = true
        XCTAssertEqual(testee.state, .submitted)
    }

    func testFailedState() {
        let testee: FileSubmission = databaseClient.insert()
        testee.submissionError = "error"
        XCTAssertEqual(testee.state, .failedSubmission(message: "error"))
    }

    func testStateOfFiles() {
        let file: FileUploadItem = databaseClient.insert()
        file.bytesToUpload = 10
        file.bytesUploaded = 5
        let testee: FileSubmission = databaseClient.insert()
        testee.files = Set([file])
        XCTAssertEqual(testee.state, .uploading(progress: 0.5))
    }

    func testTotalSize() {
        let file1: FileUploadItem = databaseClient.insert()
        file1.bytesToUpload = 10
        let file2: FileUploadItem = databaseClient.insert()
        file2.bytesToUpload = 22
        let testee: FileSubmission = databaseClient.insert()
        testee.files = Set([file1, file2])
        XCTAssertEqual(testee.totalSize, 32)
    }
}
