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

    private let batchId = "TestBatchId"

    override func setUp() {
        super.setUp()
        testee = AttachmentPickerViewModel(router: environment.router, batchId: batchId, uploadManager: uploadManager)
    }

    func testCancelButton() {
        let viewController = WeakViewController(UIViewController())

        testee.fileSelected(url: URL(string: "testDomain.com/testResourse1")!)
        testee.cancelButtonDidTap.accept(viewController)
        XCTAssertTrue(testee.fileList.isEmpty)
    }

    func testUploadButton() {
        let viewController = WeakViewController(UIViewController())

        let testFile = File.make()
        testee.fileSelected(url: testFile.localFileURL ?? URL(string: "test")!)
        XCTAssertTrue(uploadManager.addWasCalled)

        testee.uploadButtonDidTap.accept(viewController)
    }

    func testRetryButton() {
        let viewController = WeakViewController(UIViewController())

        let testFile = File.make()
        testee.fileSelected(url: testFile.localFileURL ?? URL(string: "test")!)
        XCTAssertTrue(uploadManager.addWasCalled)

        testee.retryButtonDidTap.accept(viewController)
    }

    func testAddAttachmentDialog() {
        let viewController = WeakViewController(UIViewController())

        testee.addAttachmentButtonDidTap.accept(viewController)
        wait(for: [router.showExpectation], timeout: 1)
        let dialog = router.presented as? BottomSheetPickerViewController
        XCTAssertNotNil(dialog)
    }
}
