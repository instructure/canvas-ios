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

@testable import Core
import CoreData
import SwiftUI
import XCTest

class FileUploadNotificationCardItemViewModelTests: CoreTestCase {
    func testUploadingStateProperties() {
        // Given
        let viewModel = createViewModel(state: .uploading)

        // Then
        XCTAssertEqual(viewModel.state.text, "Uploading Submission")
        XCTAssertEqual(viewModel.state.image, Image.share)
        XCTAssertEqual(viewModel.state.color, Color.backgroundInfo)
    }

    func testSuccessStateProperties() {
        // Given
        let viewModel = createViewModel(state: .success)

        // Then
        XCTAssertEqual(viewModel.state.text, "Submission Uploaded")
        XCTAssertEqual(viewModel.state.image, Image.checkLine)
        XCTAssertEqual(viewModel.state.color, Color.backgroundSuccess)
    }

    func testFailureStateProperties() {
        // Given
        let viewModel = createViewModel(state: .failure)

        // Then
        XCTAssertEqual(viewModel.state.text, "Submission Failed")
        XCTAssertEqual(viewModel.state.image, Image.warningBorderlessLine)
        XCTAssertEqual(viewModel.state.color, Color.backgroundDanger)
    }

    func testHideButtonDismissesCard() {
        // Given
        let completionExpectation = expectation(description: "completion fulfilled")
        let dismissDidTap = {
            completionExpectation.fulfill()
        }
        let viewModel = createViewModel(
            state: .uploading,
            dismissDidTap: dismissDidTap
        )

        // When
        viewModel.hideDidTap()

        // Then
        waitForExpectations(timeout: 1)
        XCTAssertEqual(viewModel.isHiddenByUser, true)
    }

    private func createViewModel(
        state: FileUploadNotificationCardItemViewModel.State,
        dismissDidTap: @escaping () -> Void = {}
    ) -> FileUploadNotificationCardItemViewModel {
        let submission = createSubmission()
        return FileUploadNotificationCardItemViewModel(
            id: submission.objectID,
            assignmentName: submission.assignmentName,
            state: state,
            isHiddenByUser: false,
            cardDidTap: { _, _ in },
            dismissDidTap: dismissDidTap
        )
    }

    private func createSubmission() -> FileSubmission {
        let submission: FileSubmission = databaseClient.insert()
        submission.assignmentID = "assignmentID"
        submission.courseID = "courseID"

        let file: FileUploadItem = databaseClient.insert()
        submission.files = Set([file])

        return submission
    }

    private func saveFiles() {
        try! databaseClient.save()
    }
}
