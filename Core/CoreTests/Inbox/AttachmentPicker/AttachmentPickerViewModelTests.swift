//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

import Foundation
import Combine
@testable import Core
import CoreData
import XCTest

class AttachmentPickerViewModelTests: CoreTestCase {
    var testee: AttachmentPickerViewModel!

    private let interactor = AttachmentPickerInteractorPreview()

    override func setUp() {
        super.setUp()
        testee = AttachmentPickerViewModel(router: environment.router, interactor: interactor)
    }

    func testCancelButton() {
        let viewController = WeakViewController(UIViewController())

        testee.didSelectFile(url: URL(string: "testDomain.com/testResourse1")!)
        testee.cancelButtonDidTap.accept(viewController)
        XCTAssertTrue(testee.fileList.isEmpty)
    }

    func testUploadButton() {
        let viewController = WeakViewController(UIViewController())

        let testFile = File.make()
        testee.didSelectFile(url: testFile.localFileURL ?? URL(string: "test")!)
        XCTAssertTrue(interactor.addFileCalled)

        testee.uploadButtonDidTap.accept(viewController)
        XCTAssertTrue(interactor.uploadFilesCalled)
    }

    func testRetryButton() {
        let viewController = WeakViewController(UIViewController())

        let testFile = File.make()
        testee.didSelectFile(url: testFile.localFileURL ?? URL(string: "test")!)
        XCTAssertTrue(interactor.addFileCalled)

        testee.retryButtonDidTap.accept(viewController)
        XCTAssertTrue(interactor.retryCalled)
    }

    func testAddAttachmentDialog() {
        let viewController = WeakViewController(UIViewController())

        testee.addAttachmentButtonDidTap.accept(viewController)
        wait(for: [router.showExpectation], timeout: 1)
        let dialog = router.presented as? BottomSheetPickerViewController
        XCTAssertNotNil(dialog)
    }

    func testErrorHandling() {
        interactor.throwError()

        wait(for: [router.showExpectation], timeout: 1)
        let dialog = router.presented as? UIAlertController
        XCTAssertNotNil(dialog)
        XCTAssertEqual(dialog?.title, "Error")
        XCTAssertEqual(dialog?.message, "Failed to add attachment. Please try again!")
        XCTAssertEqual(dialog?.actions.count, 1)
    }

    func testFileDelete() {
        testee.deleteFileButtonDidTap.accept(File.make())

        XCTAssertTrue(interactor.deleteFileCalled)
    }

    func testFileRemove() {
        testee.removeButtonDidTap.accept(File.make())

        XCTAssertTrue(interactor.removeFileCalled)
    }

    func testFileOpen() {
        router.mock("https://canvas.instructure.com/files/1?canEdit=false", factory: { FileDetailsViewController() })
        let file = File.make(from: APIFile.make(url: URL(string: "https://canvas.instructure.com/files/1")!))
        testee.fileSelected.accept((WeakViewController(), file))

        wait(for: [router.showExpectation], timeout: 1)
        let viewController = router.presented as? FileDetailsViewController
        XCTAssertNotNil(viewController)
    }

    func testFileOpenError() {
        let file = File.make(from: APIFile.make(url: URL(string: "https://canvas.instructure.com/files/2")!))
        testee.fileSelected.accept((WeakViewController(), file))

        wait(for: [router.showExpectation], timeout: 1)
        let viewController = router.presented as? UIAlertController
        XCTAssertNotNil(viewController)
    }
}
