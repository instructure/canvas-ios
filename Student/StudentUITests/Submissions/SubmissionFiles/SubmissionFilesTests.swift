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

import Foundation
import XCTest
@testable import Core
import TestsFoundation

class SubmissionFilesTests: CoreUITestCase {
    lazy var course = mock(course: .make())

    lazy var assignment: APIAssignment = {
        let assignment = APIAssignment.make()
        mockData(GetAssignmentRequest(courseID: course.id.value, assignmentID: assignment.id.value, include: []), value: assignment)
        return assignment
    }()

    func testFilesList() {
        mockBaseRequests()
        let attachments = [
            APIFile.make(id: "1", display_name: "File 1"),
            APIFile.make(id: "2", display_name: "File 2"),
        ]
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            user_id: "1",
            submission_type: .online_upload,
            attachments: attachments
        ))
        attachments.forEach { mockURL($0.url!.rawValue, data: nil) }

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerFilesButton.tap()

        XCTAssertTrue(SubmissionFiles.cell(fileID: "1").isVisible)

        XCTAssertTrue(SubmissionFiles.checkView(fileID: "1").isVisible)
        XCTAssertTrue(SubmissionFiles.cell(fileID: "2").isVisible)
        XCTAssertFalse(SubmissionFiles.checkView(fileID: "2").isVisible)

        SubmissionFiles.cell(fileID: "2").tap()

        XCTAssertFalse(SubmissionFiles.checkView(fileID: "1").isVisible)
        XCTAssertTrue(SubmissionFiles.checkView(fileID: "2").isVisible)
    }
}
