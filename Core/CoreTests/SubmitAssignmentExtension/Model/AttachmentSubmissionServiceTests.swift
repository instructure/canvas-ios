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

        let testee = AttachmentSubmissionService(submissionAssembly: .makeShareExtensionAssembly())
        let submissionID = testee.submit(urls: [fileURL], courseID: "testCourseID", assignmentID: "testAssignmentID", comment: "testComment")
        RunLoop.main.run(until: Date() + 0.1)

        let viewContext = AppEnvironment.shared.database.viewContext
        XCTAssertEqual(viewContext.registeredObjects.count, 2) // submission + item

        let scope = Scope(predicate: NSPredicate(format: "SELF = %@", submissionID), order: [])

        guard let submission = (viewContext.fetch(scope: scope) as [FileSubmission]).first else {
            XCTFail("Submission not created")
            return
        }

        XCTAssertEqual(submission.assignmentID, "testAssignmentID")
        XCTAssertEqual(submission.courseID, "testCourseID")
        XCTAssertEqual(submission.comment, "testComment")

        guard submission.files.count == 1, let uploadItem = submission.files.first else {
            XCTFail("File upload item not created")
            return
        }

        XCTAssertEqual(uploadItem.fileSize, 4)
        XCTAssertEqual(uploadItem.localFileURL, fileURL)
    }
}
