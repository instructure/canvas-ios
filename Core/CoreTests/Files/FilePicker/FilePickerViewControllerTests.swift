//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
import VisionKit

class FilePickerViewControllerTests: CoreTestCase, FilePickerControllerDelegate {
    var cancelled = false
    func cancel(_ controller: FilePickerViewController) {
        cancelled = true
    }

    var submitted = false
    func submit(_ controller: FilePickerViewController) {
        submitted = true
    }

    var retried = false
    func retry(_ controller: FilePickerViewController) {
        retried = true
    }

    func canSubmit(_ controller: FilePickerViewController) -> Bool {
        return true
    }

    let batchID = "1"

    lazy var controller = FilePickerViewController.create(batchID: batchID)

    func testLayout() {
        let navigation = UINavigationController(rootViewController: controller)
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.view.backgroundColor, .named(.backgroundLightest))
        XCTAssertTrue(controller.progressView.isHidden)
        XCTAssertEqual(controller.sourcesTabBar.items?.count, 4)
        XCTAssertEqual(navigation.navigationBar.barTintColor, .named(.backgroundLightest))
    }

    func testDocument() {
        let url = URL.temporaryDirectory.appendingPathComponent("FilePickerViewControllerTests-document.txt")
        XCTAssertTrue(FileManager.default.createFile(atPath: url.path, contents: "hello".data(using: .utf8)))

        controller.delegate = self
        controller.view.layoutIfNeeded()
        let tabBar = controller.sourcesTabBar!
        tabBar.delegate?.tabBar?(tabBar, didSelect: tabBar.items![FilePickerSource.files.rawValue])
        let picker = router.presented as! UIDocumentPickerViewController
        picker.delegate?.documentPicker?(picker, didPickDocumentsAt: [url])

        let index = IndexPath(row: 0, section: 0)
        var row = controller.tableView.cellForRow(at: index) as? FilePickerCell
        XCTAssertEqual(row?.accessibilityIdentifier, "FilePickerListItem.0")
        XCTAssertEqual(row?.subtitleLabel.text, "5 bytes")

        let submitItem = controller.navigationItem.rightBarButtonItem
        _ = submitItem?.target?.perform(submitItem?.action)
        XCTAssertTrue(submitted)

        // Progress
        UploadManager.shared.viewContext.performAndWait {
            let file = controller.files.first!
            file.taskID = "1"
            file.bytesSent = 2
            try? UploadManager.shared.viewContext.save()
        }
        XCTAssertEqual(controller.progressView.progress, 2/5)
        let cancelItem = controller.toolbarItems?[1]
        XCTAssertEqual(cancelItem?.title, controller.cancelButtonTitle)

        _ = cancelItem?.target?.perform(cancelItem?.action)
        XCTAssertTrue(cancelled)

        // Error
        UploadManager.shared.viewContext.performAndWait {
            let file = controller.files.first!
            file.taskID = nil
            file.uploadError = "Oops"
            try? UploadManager.shared.viewContext.save()
        }
        row = controller.tableView.cellForRow(at: index) as? FilePickerCell
        XCTAssertEqual(row?.subtitleLabel.text, "Failed upload")

        controller.tableView.delegate?.tableView?(controller.tableView, didSelectRowAt: index)
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Oops")

        // Retry
        let retryItem = controller.toolbarItems?[2]
        XCTAssertEqual(retryItem?.title, "Retry")
        _ = retryItem?.target?.perform(retryItem?.action)
        XCTAssertTrue(retried)
    }

    func testImage() {
        controller.view.layoutIfNeeded()
        let tabBar = controller.sourcesTabBar!
        tabBar.delegate?.tabBar?(tabBar, didSelect: tabBar.items![FilePickerSource.camera.rawValue])
        XCTAssertNil(router.presented) // camera is unsupported in simulator
        tabBar.delegate?.tabBar?(tabBar, didSelect: tabBar.items![FilePickerSource.library.rawValue])
        let picker = router.presented as! UIImagePickerController
        picker.delegate?.imagePickerController?(MockImagePicker(), didFinishPickingMediaWithInfo: [
            .originalImage: UIImage.icon(.instructure),
        ])

        let index = IndexPath(row: 0, section: 0)
        let row = controller.tableView.cellForRow(at: index) as? FilePickerCell
        XCTAssertEqual(row?.accessibilityIdentifier, "FilePickerListItem.0")
        XCTAssertEqual(row?.subtitleLabel.text?.contains(" KB"), true)

        picker.delegate?.imagePickerController?(MockImagePicker(), didFinishPickingMediaWithInfo: [
            .mediaURL: URL.temporaryDirectory.appendingPathComponent("bogus"),
        ])
        XCTAssert(router.presented is UIAlertController)

        UploadManager.shared.viewContext.performAndWait {
            let file = controller.files.first!
            file.taskID = "1"
            file.bytesSent = 100
            try? UploadManager.shared.viewContext.save()
        }

        let doneItem = controller.navigationItem.rightBarButtonItem
        XCTAssertEqual(doneItem?.title, "Done")
        XCTAssertNoThrow(doneItem?.target?.perform(doneItem?.action))
    }

    @available(iOS 13.0, *)
    func testDocumentScan() {
        controller.sources = [.documentScan]
        controller.view.layoutIfNeeded()
        let tabBar = controller.sourcesTabBar!
        tabBar.delegate?.tabBar?(tabBar, didSelect: tabBar.items!.first!)
        XCTAssertNil(router.presented, "document scanner not supported in simulator")
    }
}

class MockImagePicker: UIImagePickerController {
    var dismissed = false
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        dismissed = true
        completion?()
    }
}
