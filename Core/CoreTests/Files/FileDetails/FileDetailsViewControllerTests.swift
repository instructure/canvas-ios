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

import AVKit
import XCTest
import PSPDFKit
import PSPDFKitUI
import QuickLook
@testable import Core
import TestsFoundation

class FileDetailsViewControllerTests: CoreTestCase {
    let file = APIFile.make()
    var context = Context(.course, id: "2")
    lazy var controller = FileDetailsViewController.create(context: context, fileID: "1", assignmentID: "3")
    var navigation: UINavigationController!
    var saveWasCalled = false
    var didSaveExpectation: XCTestExpectation!

    override func setUp() {
        super.setUp()
        navigation = UINavigationController(rootViewController: controller)
        api.mock(controller.files, value: file)
        api.mockDownload(file.url!.rawValue)
        saveWasCalled = false
        didSaveExpectation = XCTestExpectation(description: "did save")
        BackgroundVideoPlayer.shared.disconnect()
    }

    override func tearDown() {
        super.tearDown()
        if let url = controller.localURL, FileManager.default.fileExists(atPath: url.path) {
            XCTAssertNoThrow(try FileManager.default.removeItem(at: url))
        }
        BackgroundVideoPlayer.shared.disconnect()
    }

    func testLayout() {
        controller.view.layoutIfNeeded()
        XCTAssertEqual(controller.view.backgroundColor, .named(.backgroundLightest))
        XCTAssertFalse(controller.spinnerView.isHidden)
        XCTAssertFalse(controller.progressView.isHidden)

        XCTAssertEqual(controller.title, file.display_name)
    }

    func testLastCourseAssignment() {
        controller.view.layoutIfNeeded()
        controller.viewWillAppear(false)
        XCTAssertEqual(controller.env.userDefaults?.submitAssignmentCourseID, "2")
        XCTAssertEqual(controller.env.userDefaults?.submitAssignmentID, "3")

        controller.assignmentID = nil
        controller.context = Context.currentUser
        controller.viewWillAppear(false)
        XCTAssertNil(controller.env.userDefaults?.submitAssignmentCourseID)
        XCTAssertNil(controller.env.userDefaults?.submitAssignmentID)
    }

    func testCancel() {
        controller.view.layoutIfNeeded()
        let task = controller.downloadTask as! MockURLSession.MockDownloadTask
        XCTAssertFalse(task.canceled)
        controller.viewWillDisappear(false)
        XCTAssertTrue(task.canceled)
    }

    func testFileError() {
        api.mock(controller.files, error: NSError.instructureError("Nope"))
        controller.view.layoutIfNeeded()
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "Nope")
    }

    func testDownload() {
        let url = URL.temporaryDirectory.appendingPathComponent("\(currentSession.uniqueID)/1/File.jpg")
        XCTAssertNoThrow(try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true))
        FileManager.default.createFile(atPath: url.path, contents: Data())
        controller.view.layoutIfNeeded()
        XCTAssertNil(controller.downloadTask)

        XCTAssertNoThrow(try FileManager.default.removeItem(at: url))
        controller.downloadFile(at: file.url!.rawValue) // restart download without local file
        let session = MockURLSession()
        let task = controller.downloadTask as! MockURLSession.MockDownloadTask

        // Updates progress
        controller.urlSession(session, downloadTask: task, didWriteData: 5, totalBytesWritten: 65, totalBytesExpectedToWrite: 100)
        XCTAssertEqual(controller.progressView.progress, 0.65)

        // Overwrites existing file
        FileManager.default.createFile(atPath: url.path, contents: Data())
        let temp = URL.temporaryDirectory.appendingPathComponent(UUID.string)
        FileManager.default.createFile(atPath: temp.path, contents: "hi".data(using: .utf8))
        controller.urlSession(session, downloadTask: task, didFinishDownloadingTo: temp)
        XCTAssertNil(router.presented) // no error
        XCTAssertFalse(FileManager.default.fileExists(atPath: temp.path))
        XCTAssertEqual(try? Data(contentsOf: url), "hi".data(using: .utf8))

        // Creates intermediate directories
        XCTAssertNoThrow(try FileManager.default.removeItem(at: url))
        XCTAssertNoThrow(try FileManager.default.removeItem(at: url.deletingLastPathComponent()))
        FileManager.default.createFile(atPath: temp.path, contents: "mkdir -p".data(using: .utf8))
        controller.urlSession(session, downloadTask: task, didFinishDownloadingTo: temp)
        XCTAssertNil(router.presented) // no error
        XCTAssertFalse(FileManager.default.fileExists(atPath: temp.path))
        XCTAssertEqual(try? Data(contentsOf: url), "mkdir -p".data(using: .utf8))

        // Shows errors in file moving
        // temp doesn't exist
        controller.urlSession(session, downloadTask: task, didFinishDownloadingTo: temp)
        XCTAssertNotNil(router.presented)
        router.viewControllerCalls = []

        // Doesn't alert cancellations
        controller.urlSession(session, task: task, didCompleteWithError: NSError(domain: "", code: NSURLErrorCancelled, userInfo: nil))
        XCTAssertNil(router.presented)
        XCTAssertTrue(session.finishedTasksAndInvalidated)

        // Does alert other errors
        controller.urlSession(session, task: task, didCompleteWithError: NSError.instructureError("boo"))
        XCTAssertEqual((router.presented as? UIAlertController)?.message, "boo")
    }

    func mock(_ file: APIFile, isExistingPDFFileWithAnnotations: Bool = false) {
        api.mock(controller.files, value: file)
        let base = isExistingPDFFileWithAnnotations ? URL.documentsDirectory : URL.temporaryDirectory
        let url = base.appendingPathComponent("\(currentSession.uniqueID)/1/\(file.filename)")
        XCTAssertNoThrow(try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true))
        XCTAssertTrue(FileManager.default.createFile(atPath: url.path, contents: Data()))
    }

    func testAudio() {
        mock(APIFile.make(filename: "File.m4a", contentType: "audio/m4a", mime_class: "audio"))
        controller.view.layoutIfNeeded()
        XCTAssertTrue(controller.spinnerView.isHidden)
        XCTAssertTrue(controller.progressView.isHidden)
        XCTAssert(controller.children.first is AudioPlayerViewController)
    }

    func testImage() {
        let file = APIFile.make(filename: "File.heic", contentType: "image/heic", mime_class: "file")
        mock(file)
        controller.view.layoutIfNeeded()
        XCTAssertTrue(controller.spinnerView.isHidden)
        XCTAssertTrue(controller.progressView.isHidden)
        XCTAssert(controller.contentView.subviews.first is UIScrollView)
        XCTAssertEqual(controller.contentView.subviews[0].subviews[0].accessibilityIdentifier, "FileDetails.imageView")
        XCTAssertEqual(controller.contentView.subviews[0].subviews[0].accessibilityLabel, file.display_name)
    }

    func testModel() {
        mock(APIFile.make(filename: "File.usdz", contentType: "model/vnd.usdz+zip", mime_class: "file"))
        let done = expectation(description: "done")
        var token: NSObjectProtocol?
        token = NotificationCenter.default.addObserver(forName: .CompletedModuleItemRequirement, object: nil, queue: nil) { _ in
            NotificationCenter.default.removeObserver(token!)
            done.fulfill()
        }
        controller.view.layoutIfNeeded()
        wait(for: [done], timeout: 5)
        XCTAssertTrue(controller.spinnerView.isHidden)
        XCTAssertTrue(controller.progressView.isHidden)
        XCTAssertFalse(controller.arButton.isHidden)
        controller.arButton.sendActions(for: .primaryActionTriggered)
        let preview = router.presented as! QLPreviewController
        XCTAssertEqual(preview.dataSource?.numberOfPreviewItems(in: preview), 1)
        XCTAssertEqual(preview.dataSource?.previewController(preview, previewItemAt: 0) as? URL, controller.localURL)
    }

    func testPDF() {
        DocViewerViewController.hasPSPDFKitLicense = true
        mock(APIFile.make(filename: "File.pdf", contentType: "application/pdf", mime_class: "pdf"))
        controller.view.layoutIfNeeded()
        XCTAssertTrue(controller.spinnerView.isHidden)
        XCTAssertTrue(controller.progressView.isHidden)
        let pdf = controller.children.first as! PDFViewController
        XCTAssertTrue(controller.pdfViewController(pdf, shouldShow: UIActivityViewController(activityItems: [""], applicationActivities: nil), animated: false))
        XCTAssertFalse(controller.pdfViewController(pdf, shouldShow: StampViewController(), animated: false))

        let items = [
            MenuItem(title: "", block: {}, identifier: TextMenu.annotationMenuNote.rawValue),
            MenuItem(title: "", block: {}, identifier: TextMenu.annotationMenuInspector.rawValue),
            MenuItem(title: "", block: {}, identifier: TextMenu.annotationMenuRemove.rawValue),
        ]
        let results = controller.pdfViewController(pdf, shouldShow: items, atSuggestedTargetRect: .zero, for: [], in: .zero, on: PDFPageView(frame: .zero))
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].title, "Style")
        XCTAssertNotNil(results[1].ps_image)
        pdf.document?.delegate = self
        controller.viewWillDisappear(false)
        XCTAssertTrue(saveWasCalled)
    }

    func testPrepLocalURL() {
        let tempUrl = URL.temporaryDirectory.appendingPathComponent("\(currentSession.uniqueID)/1/File.pdf")
        mock(APIFile.make(filename: "File.pdf", contentType: "application/pdf", mime_class: "pdf"))
        controller.view.layoutIfNeeded()
        let result = controller.prepLocalURL()
        XCTAssertEqual(result, tempUrl)
    }

    func testPrepLocalURLWithExistingPDFFile() {
        let docsUrl = URL.documentsDirectory.appendingPathComponent("\(currentSession.uniqueID)/1/File.pdf")
        mock(APIFile.make(filename: "File.pdf", contentType: "application/pdf", mime_class: "pdf"), isExistingPDFFileWithAnnotations: true)
        controller.view.layoutIfNeeded()
        let result = controller.prepLocalURL()
        XCTAssertEqual(result, docsUrl)
    }

    func testMutatedPdfFileSavesToDocumentsDirectory() {
        let expectedURL = URL.documentsDirectory.appendingPathComponent("\(currentSession.uniqueID)/1/File.pdf")
        try? FileManager.default.removeItem(atPath: expectedURL.path)
        XCTAssertFalse( FileManager.default.fileExists(atPath: expectedURL.path) )
        DocViewerViewController.hasPSPDFKitLicense = true
        mock(APIFile.make(filename: "File.pdf", contentType: "application/pdf", mime_class: "pdf"))
        controller.view.layoutIfNeeded()
        let pdf = controller.children.first as! PDFViewController
        controller.pdfAnnotationsMutatedMoveToDocsDirectory = true
        guard let doc = pdf.document else { XCTFail("no pdf.document"); return }
        controller.pdfViewController(pdf, didSave: doc, error: nil)
        XCTAssertTrue( FileManager.default.fileExists(atPath: expectedURL.path) )
    }

    func testNonMutatedPdfFileStaysInTempDirectory() {
        let expectedURL = URL.temporaryDirectory.appendingPathComponent("\(currentSession.uniqueID)/1/File.pdf")
        let docsURL = URL.documentsDirectory.appendingPathComponent("\(currentSession.uniqueID)/1/File.pdf")
        try? FileManager.default.removeItem(atPath: docsURL.path)
        DocViewerViewController.hasPSPDFKitLicense = true
        mock(APIFile.make(filename: "File.pdf", contentType: "application/pdf", mime_class: "pdf"))
        XCTAssertFalse( FileManager.default.fileExists(atPath: docsURL.path) )
        controller.view.layoutIfNeeded()
        let pdf = controller.children.first as! PDFViewController
        controller.pdfAnnotationsMutatedMoveToDocsDirectory = false
        guard let doc = pdf.document else { XCTFail("no pdf.document"); return }
        controller.pdfViewController(pdf, didSave: doc, error: nil)
        XCTAssertTrue( FileManager.default.fileExists(atPath: expectedURL.path) )
        XCTAssertFalse( FileManager.default.fileExists(atPath: docsURL.path) )
    }

    func testSVG() {
        mock(APIFile.make(filename: "File.svg", contentType: "image/svg+xml", mime_class: "file"))
        controller.view.layoutIfNeeded()
        XCTAssert(controller.contentView.subviews.first is CoreWebView)
        XCTAssertNotNil(controller.loadObservation)
    }

    func testVideo() {
        mock(APIFile.make(filename: "File.m4v", contentType: "video/m4v", mime_class: "video"))
        controller.view.layoutIfNeeded()
        XCTAssertTrue(controller.spinnerView.isHidden)
        XCTAssertTrue(controller.progressView.isHidden)
        XCTAssert(controller.children.first is AVPlayerViewController)
        XCTAssert(BackgroundVideoPlayer.shared.isConnected)
        controller.viewWillDisappear(false)
        XCTAssertFalse(BackgroundVideoPlayer.shared.isConnected)
    }

    func testShare() {
        controller.view.layoutIfNeeded()
        _ = controller.shareButton.target?.perform(controller.shareButton.action, with: [controller.shareButton])
        XCTAssert(router.presented is UIActivityViewController)
    }

    func testLocked() {
        let file = APIFile.make(locked_for_user: true, lock_explanation: "Locked, yo.")
        api.mock(controller.files, value: file)
        controller.view.layoutIfNeeded()
        XCTAssertFalse(controller.lockView.isHidden)
        XCTAssertEqual(controller.lockLabel.text, "Locked, yo.")
        controller.viewModules() // not yet accessible from UI
        XCTAssertTrue(router.lastRoutedTo("/\(context.pathComponent)/modules"))
    }

    func testTeacher() {
        environment.app = .teacher
        controller.view.layoutIfNeeded()

        XCTAssert(controller.navigationItem.rightBarButtonItem == controller.editButton)
        _ = controller.editButton.target?.perform(controller.editButton.action)
        XCTAssert(router.lastRoutedTo("/\(context.pathComponent)/files/1/edit"))

        _ = controller.toolbarLinkButton.target?.perform(controller.toolbarLinkButton.action)
        XCTAssertEqual(controller.copiedView.isHidden, false)
        XCTAssertEqual(UIPasteboard.general.url, URL(string: "https://canvas.instructure.com/files/1/download"))

        _ = controller.toolbarShareButton.target?.perform(controller.toolbarShareButton.action, with: [controller.toolbarShareButton])
        XCTAssert(router.presented is UIActivityViewController)
    }
}

extension FileDetailsViewControllerTests: PDFDocumentDelegate {
    func  pdfDocumentDidSave(_ document: Document) {
        saveWasCalled = true
    }

    func pdfDocument(_ document: Document, saveDidFailWithError error: Error) {
        saveWasCalled = true // although it may have failed, it was called
    }
}
