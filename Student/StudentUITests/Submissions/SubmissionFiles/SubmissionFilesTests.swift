//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import XCTest
@testable import Core
import TestsFoundation

class SubmissionFilesTests: StudentTest {
    lazy var course: APICourse = {
        let course = APICourse.make()
        mockData(GetCourseRequest(courseID: course.id), value: course)
        return course
    }()

    lazy var assignment: APIAssignment = {
        let assignment = APIAssignment.make()
        mockData(GetAssignmentRequest(courseID: course.id, assignmentID: assignment.id.value, include: []), value: assignment)
        return assignment
    }()

    func testFilesList() {
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            user_id: "1",
            submission_type: .online_upload,
            attachments: [
                APIFile.make(id: "1", display_name: "File 1"),
                APIFile.make(id: "2", display_name: "File 2"),
            ]
        ))

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
