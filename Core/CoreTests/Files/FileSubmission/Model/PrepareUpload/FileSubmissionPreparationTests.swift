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

class FileSubmissionPreparationTests: CoreTestCase {

    func testClearFileAndSubmissionStates() {
        // MARK: - GIVEN
        let submission = databaseClient.insert() as FileSubmission
        submission.submissionError = "testError"

        let file1 = databaseClient.insert() as FileUploadItem
        file1.uploadError = "testError"
        file1.uploadTarget = FileUploadTarget(upload_url: .make(), upload_params: [:])
        file1.apiID = "test"
        file1.fileSubmission = submission
        let file2 = databaseClient.insert() as FileUploadItem
        file2.uploadError = "testError"
        file2.uploadTarget = FileUploadTarget(upload_url: .make(), upload_params: [:])
        file2.apiID = "test"
        file2.fileSubmission = submission

        // MARK: - WHEN
        FileSubmissionPreparation(context: databaseClient).prepare(submissionID: submission.objectID)

        // MARK: - THEN
        XCTAssertNil(submission.submissionError)
        XCTAssertNil(file1.uploadError)
        XCTAssertNil(file1.uploadTarget)
        XCTAssertNil(file1.apiID)
        XCTAssertNil(file2.uploadError)
        XCTAssertNil(file2.uploadTarget)
        XCTAssertNil(file2.apiID)
    }
}
