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
@testable import Horizon
import TestsFoundation
import XCTest
import Combine

final class AttachmentViewModelTests: HorizonTestCase {

    // MARK: - Properties

    private var testee: AttachmentViewModel!
    private var mockComposeMessageInteractor: ComposeMessageInteractorMock!
    private var mockAcknowledgeFileUploadInteractor: AcknowledgeFileUploadInteractorMock!
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        mockComposeMessageInteractor = ComposeMessageInteractorMock()
        mockAcknowledgeFileUploadInteractor = AcknowledgeFileUploadInteractorMock()
        testee = makeViewModel()
    }

    override func tearDown() {
        subscriptions.removeAll()
        testee = nil
        mockComposeMessageInteractor = nil
        mockAcknowledgeFileUploadInteractor = nil
        super.tearDown()
    }

    // MARK: - Helper Methods

    private func makeViewModel() -> AttachmentViewModel {
        AttachmentViewModel(
            composeMessageInteractor: mockComposeMessageInteractor,
            acknowledgeFileUploadInteractor: mockAcknowledgeFileUploadInteractor
        )
    }

    private func makeFile(id: String, isUploading: Bool = false) -> File {
        let file = File.make(in: databaseClient)
        file.id = id
        file.uploadError = isUploading ? nil : ""
        file.bytesSent = isUploading ? 0 : file.size
        return file
    }

    // MARK: - Initialization Tests

    func test_init_shouldSetInitialState() {
        XCTAssertFalse(testee.isErrorMessagePresented)
        XCTAssertEqual(testee.errorMessage, "")
        XCTAssertFalse(testee.isVisible)
        XCTAssertFalse(testee.isFilePickerVisible)
        XCTAssertFalse(testee.isImagePickerVisible)
        XCTAssertFalse(testee.isTakePhotoVisible)
        XCTAssertTrue(testee.items.isEmpty)
    }

    func test_init_shouldListenForAttachments() {
        let file = makeFile(id: "1")
        mockComposeMessageInteractor.simulateAttachments([file])
        XCTAssertEqual(testee.items.count, 1)
        XCTAssertEqual(testee.items[0].file.id, "1")
    }

    func test_init_shouldListenForFileUploadFailures() {
        let file = makeFile(id: "1")
        mockComposeMessageInteractor.simulateAttachments([file])

        let error = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Upload failed"])
        mockComposeMessageInteractor.simulateUploadFailure(error)
        XCTAssertTrue(testee.isErrorMessagePresented)
        XCTAssertEqual(testee.errorMessage, "Upload failed")
    }

    // MARK: - addFile(url:) Tests

    func test_addFile_shouldCallComposeMessageInteractor() {
        let url = URL(fileURLWithPath: "/test/file.pdf")
        let file = makeFile(id: "1")
        mockComposeMessageInteractor.addFileResult = file

        testee.addFile(url: url)

        XCTAssertEqual(mockComposeMessageInteractor.addFileCallCount, 1)
        XCTAssertEqual(mockComposeMessageInteractor.lastAddedFileURL, url)
    }

    func test_addFile_shouldAcknowledgeUpload_whenFileAdded() {
        let url = URL(fileURLWithPath: "/test/file.pdf")
        let file = makeFile(id: "1")
        mockComposeMessageInteractor.addFileResult = file

        testee.addFile(url: url)

        XCTAssertEqual(mockAcknowledgeFileUploadInteractor.acknowledgeUploadCallCount, 1)
        XCTAssertEqual(mockAcknowledgeFileUploadInteractor.lastAcknowledgedFile?.id, "1")
    }

    func test_addFile_shouldDismissAllPickers() {
        testee.isVisible = true
        testee.isFilePickerVisible = true
        testee.isImagePickerVisible = true
        testee.isTakePhotoVisible = true

        let url = URL(fileURLWithPath: "/test/file.pdf")
        let file = makeFile(id: "1")
        mockComposeMessageInteractor.addFileResult = file

        testee.addFile(url: url)

        XCTAssertFalse(testee.isVisible)
        XCTAssertFalse(testee.isFilePickerVisible)
        XCTAssertFalse(testee.isImagePickerVisible)
        XCTAssertFalse(testee.isTakePhotoVisible)
    }

    func test_addFile_shouldNotAcknowledgeUpload_whenFileNotAdded() {
        let url = URL(fileURLWithPath: "/test/file.pdf")
        mockComposeMessageInteractor.addFileResult = nil

        testee.addFile(url: url)

        XCTAssertEqual(mockAcknowledgeFileUploadInteractor.acknowledgeUploadCallCount, 0)
    }

    // MARK: - deleteAll() Tests

    func test_deleteAll_shouldRemoveAllFiles() {
        let file1 = makeFile(id: "1")
        let file2 = makeFile(id: "2")
        let file3 = makeFile(id: "3")
        mockComposeMessageInteractor.simulateAttachments([file1, file2, file3])
        testee.deleteAll()

        XCTAssertEqual(mockComposeMessageInteractor.removeFileCallCount, 3)
    }

    func test_deleteAll_whenNoFiles_shouldNotCrash() {
        mockComposeMessageInteractor.simulateAttachments([])

        testee.deleteAll()

        XCTAssertEqual(mockComposeMessageInteractor.removeFileCallCount, 0)
    }

    // MARK: - Picker Visibility Tests

    func test_chooseFile_shouldShowFilePickerAndHideOthers() {
        testee.isVisible = true
        testee.isImagePickerVisible = true
        testee.isTakePhotoVisible = true

        testee.chooseFile()

        XCTAssertTrue(testee.isFilePickerVisible)
        XCTAssertFalse(testee.isVisible)
    }

    func test_chooseImage_shouldShowImagePickerAndHideOthers() {
        testee.isVisible = true
        testee.isFilePickerVisible = true
        testee.isTakePhotoVisible = true

        testee.chooseImage()

        XCTAssertTrue(testee.isImagePickerVisible)
        XCTAssertFalse(testee.isVisible)
    }

    func test_choosePhoto_shouldShowPhotoPickerAndHideOthers() {
        testee.isVisible = true
        testee.isFilePickerVisible = true
        testee.isImagePickerVisible = true

        testee.choosePhoto()

        XCTAssertTrue(testee.isTakePhotoVisible)
        XCTAssertFalse(testee.isVisible)
    }

    func test_isPickerVisible_shouldReturnTrue_whenAnyPickerVisible() {
        testee.isFilePickerVisible = true

        XCTAssertTrue(testee.isPickerVisible)

        testee.isFilePickerVisible = false
        testee.isImagePickerVisible = true

        XCTAssertTrue(testee.isPickerVisible)

        testee.isImagePickerVisible = false
        testee.isTakePhotoVisible = true

        XCTAssertTrue(testee.isPickerVisible)

        testee.isTakePhotoVisible = false
        testee.isVisible = true

        XCTAssertTrue(testee.isPickerVisible)
    }

    func test_isPickerVisible_shouldReturnFalse_whenAllPickersHidden() {
        testee.isFilePickerVisible = false
        testee.isImagePickerVisible = false
        testee.isTakePhotoVisible = false
        testee.isVisible = false

        XCTAssertFalse(testee.isPickerVisible)
    }

    // MARK: - fileSelectionComplete(result:) Tests

    func test_fileSelectionComplete_success_shouldAddFile() {
        let url = URL(fileURLWithPath: "/test/file.pdf")
        let file = makeFile(id: "1")
        mockComposeMessageInteractor.addFileResult = file

        testee.fileSelectionComplete(result: .success(url))

        XCTAssertEqual(mockComposeMessageInteractor.addFileCallCount, 1)
        XCTAssertEqual(mockAcknowledgeFileUploadInteractor.acknowledgeUploadCallCount, 1)
    }

    func test_fileSelectionComplete_failure_shouldNotAddFile() {
        let error = NSError(domain: "test", code: 1, userInfo: nil)

        testee.fileSelectionComplete(result: .failure(error))

        XCTAssertEqual(mockComposeMessageInteractor.addFileCallCount, 0)
        XCTAssertEqual(mockAcknowledgeFileUploadInteractor.acknowledgeUploadCallCount, 0)
    }

    // MARK: - removeFile(attachment:) Tests

    func test_removeFile_shouldCallComposeMessageInteractor() {
        let file = makeFile(id: "1")
        let attachment = AttachmentFileModel(file: file)

        testee.removeFile(attachment: attachment)

        XCTAssertEqual(mockComposeMessageInteractor.removeFileCallCount, 1)
        XCTAssertEqual(mockComposeMessageInteractor.lastRemovedFile?.id, "1")
    }

    func test_removeFile_shouldRemoveCorrectFile() {
        let file1 = makeFile(id: "1")
        let file2 = makeFile(id: "2")
        mockComposeMessageInteractor.simulateAttachments([file1, file2])

        let attachment = AttachmentFileModel(file: file1)
        testee.removeFile(attachment: attachment)

        XCTAssertEqual(mockComposeMessageInteractor.lastRemovedFile?.id, "2")
    }

    // MARK: - Attachments Subscription Tests

    func test_listenForAttachments_shouldUpdateItems_whenAttachmentsChange() {
        let file1 = makeFile(id: "1")
        mockComposeMessageInteractor.simulateAttachments([file1])

        XCTAssertEqual(testee.items.count, 1)

        let file2 = makeFile(id: "2")
        mockComposeMessageInteractor.simulateAttachments([file1, file2])

        XCTAssertEqual(testee.items.count, 2)
    }

    func test_listenForAttachments_shouldMapFilesToModels() {
        let file1 = makeFile(id: "file-1")
        let file2 = makeFile(id: "file-2")
        mockComposeMessageInteractor.simulateAttachments([file1, file2])

        XCTAssertEqual(testee.items.count, 2)
        XCTAssertEqual(testee.items[0].file.id, "file-1")
        XCTAssertEqual(testee.items[1].file.id, "file-2")
    }

    func test_items_shouldReflectCurrentAttachments() {
        XCTAssertTrue(testee.items.isEmpty)
        let file = makeFile(id: "1")
        mockComposeMessageInteractor.simulateAttachments([file])

        XCTAssertEqual(testee.items.count, 1)
    }

    // MARK: - Upload Failure Tests

    func test_listenForFileUploadFailures_shouldShowError_onFailure() {
        let file = makeFile(id: "1")
        mockComposeMessageInteractor.simulateAttachments([file])

        let error = NSError(domain: "test", code: 500, userInfo: [NSLocalizedDescriptionKey: "Server error"])
        mockComposeMessageInteractor.simulateUploadFailure(error)

        XCTAssertTrue(testee.isErrorMessagePresented)
        XCTAssertEqual(testee.errorMessage, "Server error")
    }

    func test_listenForFileUploadFailures_shouldRemoveLastFile_onFailure() {
        let file = makeFile(id: "1")
        mockComposeMessageInteractor.simulateAttachments([file])

        let error = NSError(domain: "test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Upload failed"])
        mockComposeMessageInteractor.simulateUploadFailure(error)

        XCTAssertEqual(mockComposeMessageInteractor.removeFileCallCount, 1)
        XCTAssertEqual(mockComposeMessageInteractor.lastRemovedFile?.id, "1")
    }

    func test_listenForFileUploadFailures_shouldNotShowError_onSuccess() {
        mockComposeMessageInteractor.simulateUploadSuccess()

        XCTAssertFalse(testee.isErrorMessagePresented)
        XCTAssertEqual(testee.errorMessage, "")
    }

    func test_isUploading_shouldReturnFalse_whenNoFilesUploading() {
        let file1 = makeFile(id: "1", isUploading: false)
        let file2 = makeFile(id: "2", isUploading: false)
        mockComposeMessageInteractor.simulateAttachments([file1, file2])

        XCTAssertFalse(testee.isUploading)
    }

    func test_isUploading_shouldReturnFalse_whenNoFiles() {
        mockComposeMessageInteractor.simulateAttachments([])

        XCTAssertFalse(testee.isUploading)
    }
}
