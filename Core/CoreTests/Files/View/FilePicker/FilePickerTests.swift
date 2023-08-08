//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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
@testable import Core
import TestsFoundation

class FilePickerTests: CoreTestCase, FilePickerDelegate {
    private let testFileLocation = URL.Directories.temporary.appendingPathComponent("test.txt", isDirectory: false)

    var alertMessage: String?
    func showAlert(title: String?, message: String?) {
        alertMessage = message
    }

    var pickedURL: URL?
    func filePicker(didPick url: URL) {
        pickedURL = url
    }

    var retriedFile: File?
    func filePicker(didRetry file: File) {
        retriedFile = file
    }

    lazy var picker = FilePicker(delegate: self)

    func testPick() throws {
        picker.pick(from: UIViewController())
        let sheet = router.presented as? BottomSheetPickerViewController
        let actions = sheet?.actions
        var current = 0
        XCTAssertEqual(actions?[current].title, "Record Audio")
        actions?[current].action()
        let audio = router.presented as! AudioRecorderViewController
        audio.delegate?.send(audio, url: URL(string: "audio")!)
        XCTAssertEqual(pickedURL, URL(string: "audio"))
        XCTAssertNoThrow(audio.delegate?.cancel(audio))

        let mockPicker = MockImagePicker()

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            current += 1
            XCTAssertEqual(actions?[current].title, "Use Camera")
            actions?[current].action()
            let imagePicker = router.presented as! UIImagePickerController
            XCTAssertEqual(imagePicker.sourceType, .camera)
            imagePicker.delegate?.imagePickerController?(mockPicker, didFinishPickingMediaWithInfo: [
                .editedImage: UIImage(named: Panda.FilePicker.name, in: .core, compatibleWith: nil) as Any,
            ])
            XCTAssertEqual(try pickedURL?.checkResourceIsReachable(), true)
            XCTAssertNoThrow(try FileManager.default.removeItem(at: pickedURL!))
        }

        current += 1
        XCTAssertEqual(actions?[current].title, "Upload File")
        actions?[current].action()
        let docPicker = router.presented as! UIDocumentPickerViewController
        try FileManager.default.createDirectory(at: testFileLocation.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data().write(to: testFileLocation)
        docPicker.delegate?.documentPicker?(docPicker, didPickDocumentsAt: [testFileLocation])
        waitUntil(shouldFail: true) {
            // The test file should be moved to a temp location
            FileManager.default.fileExists(atPath: testFile.path)
        }
        XCTAssertNotEqual(pickedURL, testFileLocation, "The picked test file should be moved to the tmp folder.")

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            current += 1
            XCTAssertEqual(actions?[current].title, "Photo Library")
            actions?[current].action()
            let imagePicker = router.presented as! UIImagePickerController
            XCTAssertEqual(imagePicker.sourceType, .photoLibrary)
            imagePicker.delegate?.imagePickerController?(mockPicker, didFinishPickingMediaWithInfo: [
                .originalImage: UIImage(named: Panda.FilePicker.name, in: .core, compatibleWith: nil) as Any,
            ])
            XCTAssertEqual(try pickedURL?.checkResourceIsReachable(), true)
            XCTAssertNoThrow(try FileManager.default.removeItem(at: pickedURL!))
            imagePicker.delegate?.imagePickerController?(mockPicker, didFinishPickingMediaWithInfo: [
                .mediaURL: Bundle(for: FilePickerTests.self).url(forResource: "TestImage", withExtension: "png") as Any,
            ])
            XCTAssertEqual(try pickedURL?.checkResourceIsReachable(), true)
            XCTAssertNoThrow(try FileManager.default.removeItem(at: pickedURL!))

            imagePicker.delegate?.imagePickerController?(mockPicker, didFinishPickingMediaWithInfo: [
                .mediaURL: URL(string: "bogus") as Any,
            ])
            XCTAssertTrue(mockPicker.dismissed)
            XCTAssertEqual(alertMessage, "The file couldn’t be opened because the specified URL type isn’t supported.")
        }
    }

    func testShowOptions() {
        let file = File.make(uploadError: "Doh!")
        file.id = nil
        picker.showOptions(for: file, from: UIViewController())
        let actions = (router.presented as? BottomSheetPickerViewController)?.actions
        XCTAssertEqual(actions?[0].title, "Retry")
        actions?[0].action()
        XCTAssertEqual(file, retriedFile)

        XCTAssertEqual(actions?[1].title, "Delete")
        actions?[1].action()
        XCTAssertEqual((UploadManager.shared as? MockUploadManager)?.cancelWasCalled, true)
    }

    func testDeleteExisting() {
        let file = File.make()
        picker.showOptions(for: file, from: UIViewController())
        let actions = (router.presented as? BottomSheetPickerViewController)?.actions
        XCTAssertEqual(actions?[0].title, "Delete")

        api.mock(DeleteFileRequest(fileID: file.id!), error: NSError.instructureError("Oops"))
        actions?[0].action()
        XCTAssertEqual((UploadManager.shared as? MockUploadManager)?.cancelWasCalled, false)
        XCTAssertEqual(alertMessage, "Oops")

        api.mock(DeleteFileRequest(fileID: file.id!), value: .make())
        actions?[0].action()
        XCTAssertEqual((UploadManager.shared as? MockUploadManager)?.cancelWasCalled, true)
    }
}
