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

import XCTest
import Core

class FileUploadItemTests: CoreTestCase {

    func testCalculatedProgress() {
        let testee: FileUploadItem = databaseClient.insert()

        testee.bytesUploaded = -1
        testee.bytesToUpload = 100
        XCTAssertEqual(testee.uploadProgress, 0.0, accuracy: 0.01)

        testee.bytesUploaded = 0
        testee.bytesToUpload = 100
        XCTAssertEqual(testee.uploadProgress, 0.0, accuracy: 0.01)

        testee.bytesUploaded = 50
        testee.bytesToUpload = 100
        XCTAssertEqual(testee.uploadProgress, 0.5, accuracy: 0.01)

        testee.bytesUploaded = 100
        testee.bytesToUpload = 100
        XCTAssertEqual(testee.uploadProgress, 1.0, accuracy: 0.01)

        testee.bytesUploaded = 110
        testee.bytesToUpload = 100
        XCTAssertEqual(testee.uploadProgress, 1.0, accuracy: 0.01)

        testee.bytesUploaded = 100
        testee.bytesToUpload = -1
        XCTAssertEqual(testee.uploadProgress, 0.0, accuracy: 0.01)

        testee.bytesUploaded = 100
        testee.bytesToUpload = 0
        XCTAssertEqual(testee.uploadProgress, 0.0, accuracy: 0.01)
    }

    func testWaitingState() {
        let testee: FileUploadItem = databaseClient.insert()
        XCTAssertEqual(testee.state, .waiting)
    }

    func testUploadingState() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.bytesToUpload = 100
        testee.bytesUploaded = 50
        XCTAssertEqual(testee.state, .uploading(progress: 0.5))
    }

    func testErrorState() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.bytesToUpload = 100
        testee.bytesUploaded = 50
        testee.uploadError = "error"
        XCTAssertEqual(testee.state, .error(description: "error"))
    }

    func testUploadingAtEndState() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.bytesToUpload = 100
        testee.bytesUploaded = 100
        XCTAssertEqual(testee.state, .uploading(progress: 1.0))
    }

    func testUploadingFinishedState() {
        let testee: FileUploadItem = databaseClient.insert()
        testee.bytesToUpload = 100
        testee.bytesUploaded = 100
        testee.apiID = "apiID"
        XCTAssertEqual(testee.state, .uploaded)
    }

    func testFileUploadTargetPersistency() throws {
        try XCTSkipIf(true,
        """
        This test only works if the test CoreData storage uses NSSQLiteStoreType. If there are issues with the persistence
        of FileUploadItem, modify description.type = NSInMemoryStoreType to NSSQLiteStoreType in TestPersistence.swift.
        """)
        let testee: FileUploadItem = databaseClient.insert()
        testee.localFileURL = URL(string: "/toLocalFile")!
        testee.uploadTarget = FileUploadTarget(upload_url: URL(string: "/test")!, upload_params: ["testKey": "testValue"])
        XCTAssertNoThrow(try databaseClient.save())
        // Make sure we discard the FileUploadItem from the context so fetch() will read it back from the persistent store
        databaseClient.reset()

        let uploadItems = databaseClient.fetch() as [FileUploadItem]

        guard uploadItems.count == 1 else {
            XCTFail("More than one FileUploadItem was found")
            return
        }

        XCTAssertEqual(uploadItems[0].uploadTarget, FileUploadTarget(upload_url: URL(string: "/test")!, upload_params: ["testKey": "testValue"]))
    }
}
