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

@testable import Student
import XCTest

final class FileUploadCardStateTests: XCTestCase {

    private static let testData = (
        assignmentName: "some assignment name",
        otherAssignmentName: "other assignment name"
    )
    private lazy var testData = Self.testData

    // MARK: - title

    func test_title() {
        var testee = FileUploadCardState.UploadState.uploading
        XCTAssertEqual(testee.title, "Uploading Submission")

        testee = .success
        XCTAssertEqual(testee.title, "Submission Uploaded Successfully")

        testee = .failed
        XCTAssertEqual(testee.title, "Submission Upload Failed")
    }

    // MARK: - subtitleText

    func test_subtitleText_whenUploading_shouldReturnAssignmentName() {
        XCTAssertEqual(
            FileUploadCardState.UploadState.uploading.subtitleText(assignmentName: testData.assignmentName),
            testData.assignmentName
        )
    }

    func test_subtitleText_whenSuccess_shouldReturnAssignmentName() {
        XCTAssertEqual(
            FileUploadCardState.UploadState.success.subtitleText(assignmentName: testData.assignmentName),
            testData.assignmentName
        )
    }

    func test_subtitleText_whenFailed_shouldReturnErrorMessage() {
        let result = FileUploadCardState.UploadState.failed.subtitleText(assignmentName: testData.assignmentName)
        XCTAssertEqual(result, "We couldn't upload your submission.\nTry again, or come back later")
    }

    func test_subtitleText_whenFailed_shouldIgnoreAssignmentName() {
        let result1 = FileUploadCardState.UploadState.failed.subtitleText(assignmentName: testData.assignmentName)
        let result2 = FileUploadCardState.UploadState.failed.subtitleText(assignmentName: testData.otherAssignmentName)
        XCTAssertEqual(result1, result2)
    }
}
