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
import TestsFoundation
import XCTest

class FileUploadNotificationCardViewModelTests: CoreTestCase {
    private var viewModel: FileUploadNotificationCardListViewModel!

    override func setUp() {
        super.setUp()
        viewModel = FileUploadNotificationCardListViewModel(environment: environment)
    }

    override func tearDown() {
        viewModel = nil
        TestsFoundation.singleSharedTestDatabase = resetSingleSharedTestDatabase()
        super.tearDown()
    }

    func testUploadingStateMapsToUploading() {
        // Given
        createSubmission(fileUploadItem: createFileUploadItemUploading())
        saveFiles()

        guard let vm = viewModel.items.first else {
            return XCTFail("Couldn't find FileUploadNotificationCardItemViewModel")
        }

        // Then
        XCTAssertEqual(vm.state, .uploading)
    }

    func testUploadErrorStateMapsToFailure() {
        // Given
        createSubmission(fileUploadItem: createFileUploadItemUploadError())
        saveFiles()

        guard let vm = viewModel.items.first else {
            return XCTFail("Couldn't find FileUploadNotificationCardItemViewModel")
        }

        // Then
        XCTAssertEqual(vm.state, .failure)
    }

    func testSubmissionErrorStateMapsToFailure() {
        // Given
        let submission = createSubmission(fileUploadItem: createFileUploadItemUploadError())
        submission.submissionError = "error"
        saveFiles()

        guard let vm = viewModel.items.first else {
            return XCTFail("Couldn't find FileUploadNotificationCardItemViewModel")
        }

        // Then
        XCTAssertEqual(vm.state, .failure)
    }

    func testSubmittedStateMapsToSuccess() {
        // Given
        let submission = createSubmission(fileUploadItem: createFileUploadItemUploaded())
        submission.isSubmitted = true
        saveFiles()

        guard let vm = viewModel.items.first else {
            return XCTFail("Couldn't find FileUploadNotificationCardItemViewModel")
        }

        // Then
        XCTAssertEqual(vm.state, .success)
    }

    func testUserHiddenSubmissionIsNotInTheList() {
        // Given
        let submission = createSubmission(fileUploadItem: createFileUploadItem())
        submission.isHiddenOnDashboard = true
        saveFiles()

        // Then
        let isAppended = viewModel.items.contains(where: { $0.id == submission.objectID })
        XCTAssertFalse(isAppended)
    }

    func testUploadingFailsStateUpdatesToFailure() {
        // Given
        let file = createFileUploadItemUploading()
        let submission = createSubmission(fileUploadItem: file)
        saveFiles()

        guard let vm = viewModel.items.first else {
            return XCTFail("Couldn't find FileUploadNotificationCardItemViewModel")
        }

        XCTAssertEqual(vm.state, .uploading)

        // When
        submission.submissionError = "error"
        saveFiles()

        // Then
        XCTAssertEqual(viewModel.items[0].state, .failure)
    }

    func testUploadingSucceedsStateUpdatesToSuccess() {
        // Given
        let submission = createSubmission(fileUploadItem: createFileUploadItemUploading())
        saveFiles()

        guard let vm = viewModel.items.first else {
            return XCTFail("Couldn't find FileUploadNotificationCardItemViewModel")
        }

        XCTAssertEqual(vm.state, .uploading)

        // When
        submission.isSubmitted = true
        saveFiles()

        // Then
        XCTAssertEqual(viewModel.items[0].state, .success)
    }

    func testUploadingCancelledSubmissionIsRemovedFromList() {
        // Given
        let submission = createSubmission(fileUploadItem: createFileUploadItemUploading())
        saveFiles()

        guard let vm = viewModel.items.first else {
            return XCTFail("Couldn't find FileUploadNotificationCardItemViewModel")
        }

        XCTAssertEqual(vm.state, .uploading)

        // When
        databaseClient.delete(submission)
        saveFiles()

        // Then
        XCTAssertTrue(databaseClient.isObjectDeleted(submission))
        XCTAssertFalse(viewModel.items.contains(where: { $0.id == submission.objectID }))
    }

    private func createFileUploadItemUploading() -> FileUploadItem {
        let file: FileUploadItem = databaseClient.insert()
        file.bytesToUpload = 10
        file.bytesUploaded = 5
        file.localFileURL = URL(string: "/file")!
        return file
    }

    private func createFileUploadItemUploadError() -> FileUploadItem {
        let file: FileUploadItem = databaseClient.insert()
        file.localFileURL = URL(string: "/file")!
        file.uploadError = "error"
        return file
    }

    private func createFileUploadItemUploaded() -> FileUploadItem {
        let file: FileUploadItem = databaseClient.insert()
        file.bytesToUpload = 10
        file.bytesUploaded = 10
        file.localFileURL = URL(string: "/file")!
        return file
    }

    private func createFileUploadItem() -> FileUploadItem {
        let file: FileUploadItem = databaseClient.insert()
        file.localFileURL = URL(string: "/file")!
        return file
    }

    @discardableResult
    private func createSubmission(fileUploadItem: FileUploadItem) -> FileSubmission {
        let submission: FileSubmission = databaseClient.insert()
        submission.assignmentID = "assignmentID"
        submission.courseID = "courseID"
        submission.files = Set([fileUploadItem])
        submission.isHiddenOnDashboard = false
        return submission
    }

    private func saveFiles() {
        try! databaseClient.save()
        drainMainQueue()
    }
}
