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

class FileSubmissionStateTests: XCTestCase {

    func testWaiting() {
        let testee = FileSubmission.State([
            .waiting,
            .waiting,
        ])
        XCTAssertEqual(testee, .waiting)
    }

    // MARK: - Uploading

    func testUploadingWhileOthersWaiting() {
        let testee = FileSubmission.State([
            .waiting,
            .uploading(progress: 0.2),
        ])
        XCTAssertEqual(testee, .uploading(progress: 0.1))
    }

    func testUploadingWhileOthersFailed() {
        let testee = FileSubmission.State([
            .error(description: "error"),
            .uploading(progress: 0.2),
        ])
        XCTAssertEqual(testee, .uploading(progress: 0.6))
    }

    func testUploadingWhileOthersSucceeded() {
        let testee = FileSubmission.State([
            .uploaded,
            .uploading(progress: 0.2),
        ])
        XCTAssertEqual(testee, .uploading(progress: 0.6))
    }

    func testUploading() {
        let testee = FileSubmission.State([
            .uploading(progress: 0.2),
            .uploading(progress: 0.2),
        ])
        XCTAssertEqual(testee, .uploading(progress: 0.2))
    }

    // MARK: - Upload Failed

    func testAllFailed() {
        let testee = FileSubmission.State([
            .error(description: "error"),
            .error(description: "error"),
        ])
        XCTAssertEqual(testee, .failedUpload)
    }

    func testOneFailedOneSucceeded() {
        let testee = FileSubmission.State([
            .uploaded,
            .error(description: "error"),
        ])
        XCTAssertEqual(testee, .failedUpload)
    }

    // MARK: - Completed

    func testFileUploadFinished() {
        let testee = FileSubmission.State([
            .uploaded,
            .uploaded,
        ])
        XCTAssertEqual(testee, .uploading(progress: 1))
    }
}
