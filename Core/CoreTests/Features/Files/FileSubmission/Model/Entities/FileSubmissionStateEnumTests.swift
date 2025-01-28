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

class FileSubmissionStateEnumTests: XCTestCase {

    func testWaiting() {
        let testee = FileSubmission.State([
            .waiting,
            .waiting
        ])
        XCTAssertEqual(testee, .waiting)
    }

    // MARK: - Uploading

    func testUploadingWhileOthersIsReadyForUpload() {
        let testee = FileSubmission.State([
            .readyForUpload,
            .uploading(progress: 0.2)
        ])
        XCTAssertEqual(testee, .uploading)
    }

    func testUploadingWhileOthersFailed() {
        let testee = FileSubmission.State([
            .error(description: "error"),
            .uploading(progress: 0.2)
        ])
        XCTAssertEqual(testee, .uploading)
    }

    func testUploadingWhileOthersSucceeded() {
        let testee = FileSubmission.State([
            .uploaded,
            .uploading(progress: 0.2)
        ])
        XCTAssertEqual(testee, .uploading)
    }

    func testUploading() {
        let testee = FileSubmission.State([
            .uploading(progress: 0.2),
            .uploading(progress: 0.2)
        ])
        XCTAssertEqual(testee, .uploading)
    }

    func testWaitingWhileOtherIsReadyForUpload() {
        let testee = FileSubmission.State([
            .uploaded,
            .readyForUpload
        ])
        XCTAssertEqual(testee, .uploading)
    }

    // MARK: - Upload Failed

    func testAllFailed() {
        let testee = FileSubmission.State([
            .error(description: "error"),
            .error(description: "error")
        ])
        XCTAssertEqual(testee, .failedUpload)
    }

    func testOneFailedOneSucceeded() {
        let testee = FileSubmission.State([
            .uploaded,
            .error(description: "error")
        ])
        XCTAssertEqual(testee, .failedUpload)
    }

    func testOneFailedOneWaiting() {
        let testee = FileSubmission.State([
            .waiting,
            .error(description: "error")
        ])
        XCTAssertEqual(testee, .waiting)
    }

    func testOneFailedOneReadyForUpload() {
        let testee = FileSubmission.State([
            .readyForUpload,
            .error(description: "error")
        ])
        XCTAssertEqual(testee, .failedUpload)
    }

    // MARK: - Completed

    func testFileUploadFinished() {
        let testee = FileSubmission.State([
            .uploaded,
            .uploaded
        ])
        XCTAssertEqual(testee, .uploading)
    }
}
