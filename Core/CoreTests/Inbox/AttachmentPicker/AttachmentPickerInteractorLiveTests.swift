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
import TestsFoundation
import CoreData
import XCTest

class AttachmentPickerInteractorLiveTests: CoreTestCase {
    var testee: AttachmentPickerInteractorLive!

    private let batchId: String = "testBatchId"
    private let file1 = File.make(from: .make(
        id: "p1",
        display_name: "PDF File 1",
        contentType: "application/pdf",
        url: URL(string: "/files/d?download=1")!,
        mime_class: "pdf"
    ))
    private let file2 = File.make(from: .make(
        id: "p2",
        display_name: "PDF File 2",
        contentType: "application/pdf",
        url: URL(string: "/files/d?download=2")!,
        mime_class: "pdf"
    ))

    override func setUp() {
        super.setUp()
        testee = AttachmentPickerInteractorLive(batchId: batchId, uploadManager: uploadManager)
    }

    func testAddFile() {
        testee.addFile(url: file1.url!)
        XCTAssertTrue(uploadManager.addWasCalled)
    }

    func testUpload() {
        testee.addFile(url: file1.url!)
        testee.uploadFiles()
        XCTAssertTrue(file1.isUploaded)

        testee.addFile(url: file2.url!)
        testee.uploadFiles()
        XCTAssertTrue(file2.isUploaded)
    }

    func testCancel() {
        testee.addFile(url: file1.url!)
        testee.uploadFiles()
        XCTAssertTrue(file1.isUploaded)

        testee.addFile(url: file2.url!)

        testee.cancel()
    }

    func testRetry() {
        testee.addFile(url: file1.url!)
        testee.uploadFiles()
        XCTAssertTrue(file1.isUploaded)

        testee.addFile(url: file2.url!)
        testee.retry()
        XCTAssertTrue(file2.isUploaded)
    }

}
