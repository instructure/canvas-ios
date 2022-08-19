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

class FileSubmissionComposerTests: CoreTestCase {

    func testCreatesSubmissionWithItems() {
        let testee = FileSubmissionComposer(context: databaseClient)
        let submissionID = testee.makeNewSubmission(courseId: "testCourseID",
                                                    assignmentId: "testAssignmentID",
                                                    comment: "testComment",
                                                    files: [
                                                        URL(string: "/test")!,
                                                        URL(string: "/test2")!,
                                                    ])
        guard let submission = try? databaseClient.existingObject(with: submissionID) as? FileSubmission else {
            XCTFail("Submission not found")
            return
        }

        XCTAssertEqual(submission.courseID, "testCourseID")
        XCTAssertEqual(submission.assignmentID, "testAssignmentID")
        XCTAssertEqual(submission.comment, "testComment")

        guard submission.files.count == 2 else {
            XCTFail("Incorrect number of files.")
            return
        }

        XCTAssertEqual(Set(submission.files.map { $0.localFileURL }), Set([URL(string: "/test")!, URL(string: "/test2")!]))
        XCTAssertTrue(submission.files.allSatisfy { $0.apiID == nil })
        XCTAssertTrue(submission.files.allSatisfy { $0.bytesUploaded == 0 })
        XCTAssertTrue(submission.files.allSatisfy { $0.bytesToUpload == 0 })
        XCTAssertTrue(submission.files.allSatisfy { $0.uploadError == nil })
    }

    func testDeleteItem() {
        let testee = FileSubmissionComposer(context: databaseClient)
        let submissionID = testee.makeNewSubmission(courseId: "testCourseID",
                                                    assignmentId: "testAssignmentID",
                                                    comment: "testComment",
                                                    files: [
                                                        URL(string: "/test")!,
                                                    ])

        guard let submission = try? databaseClient.existingObject(with: submissionID) as? FileSubmission else {
            XCTFail("Submission not found")
            return
        }

        let itemID = submission.files.first!.objectID
        testee.deleteItem(itemID: itemID)
        drainMainQueue()

        XCTAssertThrowsError(try databaseClient.existingObject(with: itemID))
        XCTAssertEqual(submission.files.count, 0)
    }

    func testDeleteSubmission() {
        let testee = FileSubmissionComposer(context: databaseClient)
        let submissionID = testee.makeNewSubmission(courseId: "testCourseID",
                                                    assignmentId: "testAssignmentID",
                                                    comment: "testComment",
                                                    files: [
                                                        URL(string: "/test")!,
                                                    ])
        testee.deleteSubmission(submissionID: submissionID)
        drainMainQueue()
        XCTAssertThrowsError(try databaseClient.existingObject(with: submissionID))
    }
}
