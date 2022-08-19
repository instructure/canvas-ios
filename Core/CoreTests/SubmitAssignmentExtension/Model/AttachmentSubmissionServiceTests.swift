//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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
import XCTest

class AttachmentSubmissionServiceTests: CoreTestCase {

    func testSubmit() {
        let fileURL = URL.temporaryDirectory.appendingPathComponent("loadFileURL.txt", isDirectory: false)
        try! "test".write(to: fileURL, atomically: false, encoding: .utf8)

        let testUploadManager = UploadManager(identifier: "com.instructure.icanvas.SubmitAssignment.file-uploads", sharedContainerIdentifier: "group.instructure.shared")

        let testee = AttachmentSubmissionService(uploadManager: testUploadManager)
        testee.submit(urls: [fileURL], courseID: "testCourseID", assignmentID: "testAssignmentID", batchID: "testBatch", comment: "testComment")
        RunLoop.main.run(until: Date() + 0.1)

        XCTAssertEqual(testUploadManager.viewContext.registeredObjects.count, 1) // One file added

        guard let file = (testUploadManager.viewContext.fetch(scope: .all(orderBy: "batchID")) as [File]).first else {
            XCTFail("File not saved")
            return
        }

        XCTAssertEqual(file.batchID, "testBatch")
        XCTAssertEqual(file.filename, "loadFileURL.txt")
    }
}
