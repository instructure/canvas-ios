//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

import UIKit
import WebKit
import XCTest
@testable import Core
import CoreData
import TestsFoundation

class RichContentEditorViewControllerTests: CoreTestCase, RichContentEditorDelegate {
    private let context = Context(.course, id: "1")
    private var controller: RichContentEditorViewController!

    private var canSubmit: Bool?
    func rce(_ editor: RichContentEditorViewController, canSubmit: Bool) {
        self.canSubmit = canSubmit
        self.updated?.fulfill()
    }

    private var isUploading: Bool?
    func rce(_ editor: RichContentEditorViewController, isUploading: Bool) {
        self.isUploading = isUploading
    }

    private var error: Error?
    func rce(_ editor: RichContentEditorViewController, didError error: Error) {
        self.error = error
    }

    private var updated: XCTestExpectation?

    override func setUp() {
        super.setUp()
        api.mock(GetEnabledFeatureFlagsRequest(context: context), value: ["rce_enhancements"])
        controller = RichContentEditorViewController.create(context: context, uploadTo: .myFiles)
        controller.delegate = self
        controller.placeholder = "Tests are the bests"
        update { controller.view.layoutIfNeeded() }
        controller.focus()
    }

    private func update(_ block: () -> Void) {
        updated = expectation(description: "updated")
        block()
        wait(for: [updated!], timeout: 10)
        updated = nil
    }

    private func getHTML() -> String {
        let updated = expectation(description: "updated")
        var html = ""
        controller.getHTML { value in
            html = value
            updated.fulfill()
        }
        wait(for: [updated], timeout: 5)
        return html
    }

    func testBasicCommands() {
        // poll instead of expectations to reduce flakiness
        update { controller.toolbar.unorderedButton?.sendActions(for: .primaryActionTriggered) }
        waitUntil { controller.toolbar.unorderedButton?.isSelected == true }
        waitUntil { controller.toolbar.undoButton?.isEnabled == true }

        update { controller.toolbar.orderedButton?.sendActions(for: .primaryActionTriggered) }
        waitUntil { controller.toolbar.orderedButton?.isSelected == true }
        waitUntil { controller.toolbar.unorderedButton?.isSelected == false }

        update { controller.toolbar.undoButton?.sendActions(for: .primaryActionTriggered) }
        waitUntil { controller.toolbar.orderedButton?.isSelected == false }
        waitUntil { controller.toolbar.unorderedButton?.isSelected == true }
        waitUntil { controller.toolbar.redoButton?.isEnabled == true }

        update { controller.toolbar.redoButton?.sendActions(for: .primaryActionTriggered) }
        waitUntil { controller.toolbar.orderedButton?.isSelected == true }
        waitUntil { controller.toolbar.unorderedButton?.isSelected == false }
        waitUntil { controller.toolbar.redoButton?.isEnabled == false }

        update { controller.toolbar.boldButton?.sendActions(for: .primaryActionTriggered) }
        waitUntil { controller.toolbar.boldButton?.isSelected == true }

        update { controller.toolbar.italicButton?.sendActions(for: .primaryActionTriggered) }
        waitUntil { controller.toolbar.italicButton?.isSelected == true }
    }

    func testTextColor() {
        update { controller.setHTML("text") }
        update { controller.webView.evaluateJavaScript("""
            let range = document.createRange()
            range.selectNodeContents(content)
            let selection = getSelection()
            selection.removeAllRanges()
            selection.addRange(range)
            content.focus()
        """
        ) }
        update {
            controller.toolbar.textColorButton?.sendActions(for: .primaryActionTriggered) // show
            controller.toolbar.textColorButton?.sendActions(for: .primaryActionTriggered) // hide
            controller.toolbar.textColorButton?.sendActions(for: .primaryActionTriggered) // show again
            controller.toolbar.whiteColorButton?.sendActions(for: .primaryActionTriggered) // hide because picked
        }
        XCTAssertEqual(getHTML(), "<span style=\"color: #ffffff;\">text</span>")
        XCTAssertEqual(controller.toolbar.textColorView?.backgroundColor, UIColor(hexString: "#fff"))
    }

    func testLink() {
        update { controller.setHTML("!") } // insertLink has trouble if there was nothing in tests
        controller.toolbar.linkButton!.sendActions(for: .primaryActionTriggered)
        let alert = router.presented as! UIAlertController
        alert.textFields![0].text = " Splatoon 2\n"
        alert.textFields![1].text = "splatoon.ink "
        update { (alert.actions[1] as! AlertAction).handler!(alert.actions[1]) } // OK
        waitUntil { getHTML() == "<a href=\"https://splatoon.ink\">Splatoon 2</a>!" }
    }

    func testEditLinkDialog() {
        controller.updateState([
            "linkText": "Link Text",
            "linkHref": "https://instructure.com"
        ])
        controller.toolbar.linkButton!.sendActions(for: .primaryActionTriggered)
        let alert = router.presented as! UIAlertController
        XCTAssertEqual(alert.textFields![0].text, "Link Text")
        XCTAssertEqual(alert.textFields![1].text, "https://instructure.com")
    }

    func testImage() throws {
        try XCTSkipIf(true, "This test seems to be faulty and just blocks further tests for 30 secs")
        controller.toolbar.libraryButton!.sendActions(for: .primaryActionTriggered)
        XCTAssertEqual((router.presented as? UIImagePickerController)?.sourceType, .photoLibrary)
        controller.imagePickerController(MockPicker(), didFinishPickingMediaWithInfo: [:])
        XCTAssertEqual(error?.localizedDescription, "No image found from image picker")
        controller.imagePickerController(MockPicker(), didFinishPickingMediaWithInfo: [
            .originalImage: UIImage(named: "wordmark", in: .core, compatibleWith: nil) as Any
        ])
        let context = controller.uploadManager.viewContext
        context.performAndWait {
            let file: File? = databaseClient.fetch().first
            XCTAssertNotNil(file)
            file!.uploadError = "Failure"
            try! context.save()
        }
        let files: () -> [File] = { self.databaseClient.fetch() }
        XCTAssertTrue(files().isEmpty)

        controller.webView.evaluateJavaScript("document.querySelector('.retry-upload').onclick()")
        waitUntil(30) { !files().isEmpty }
    }

    func testBadMedia() {
        controller.toolbar.cameraButton?.sendActions(for: .primaryActionTriggered)
        XCTAssert(router.presented is UIImagePickerController)
        controller.imagePickerController(MockPicker(), didFinishPickingMediaWithInfo: [
            .mediaURL: URL(string: "data:video/mp4,")!
        ])
        XCTAssertTrue((self.databaseClient.fetch() as [File]).isEmpty)
        XCTAssertNotNil(error)
    }

    func testMediaRetry() {
        UUID.mock("abc")
        let originalUrl = Bundle(for: type(of: self)).url(forResource: "instructure", withExtension: "pdf")!
        // File will get deleted after upload, so use a copy instead
        let url = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("instructure.pdf", isDirectory: false)
        try? FileManager.default.copyItem(at: originalUrl, to: url)

        api.mock(GetMediaServiceRequest(), error: NSError.internalError())
        controller.imagePickerController(MockPicker(), didFinishPickingMediaWithInfo: [ .mediaURL: url ])
        let copiedTo = URL.Directories.temporary
            .appendingPathComponent("uploads", isDirectory: true)
            .appendingPathComponent(UUID.string, isDirectory: true)
            .appendingPathComponent("instructure.pdf")
        XCTAssertTrue(FileManager.default.fileExists(atPath: copiedTo.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url.path))
        XCTAssertTrue((self.databaseClient.fetch() as [File]).isEmpty)

        controller.webView.evaluateJavaScript("document.querySelector('.retry-upload').onclick()")
        wait(for: [expectation(for: .all, evaluatedWith: self) { () -> Bool in
            (self.databaseClient.fetch() as [File]).isEmpty // still empty due to error
        } ], timeout: 5)
    }

    func testUpdateStateCallsDelegateMethods() {
        controller.updateState(["isEmpty": false, "isUploading": true])
        XCTAssertEqual(canSubmit, false)
        XCTAssertEqual(isUploading, true)

        controller.updateState(["isEmpty": false, "isUploading": false])
        XCTAssertEqual(canSubmit, true)
        XCTAssertEqual(isUploading, false)

        controller.updateState(["isEmpty": true, "isUploading": false])
        XCTAssertEqual(canSubmit, false)
        XCTAssertEqual(isUploading, false)
    }
}

private final class MockPicker: UIImagePickerController {
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        completion?()
    }
}
