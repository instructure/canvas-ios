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

class SubmissionCommentsTests: StudentTest {
    lazy var assignment: APIAssignment = seedClient.createAssignment(for: course, submissionTypes: [ .online_upload ], allowedExtensions: [ "pdf" ])
    lazy var course: APICourse = seedClient.createCourse()
    lazy var student: AuthUser = createStudent(in: course)
    lazy var teacher: AuthUser = createTeacher(in: course)

    func testCommentsList() {
        let file1 = seedClient.uploadFile(url: Bundle(for: SubmissionFilesTests.self).url(forResource: "empty", withExtension: "pdf")!, named: "File 1", for: assignment, as: student)
        let file2 = seedClient.uploadFile(url: Bundle(for: SubmissionFilesTests.self).url(forResource: "empty", withExtension: "pdf")!, named: "File 2", for: assignment, as: student)
        seedClient.submit(
            assignment: assignment,
            context: ContextModel(.course, id: course.id),
            as: student,
            submissionType: .online_upload,
            fileIDs: [ file1.id.value, file2.id.value ]
        )
        let comment1 = seedClient.commentOnSumbission(course: course, assignment: assignment, userID: student.id, as: teacher, comment: "This document is completely empty")
        let comment2 = seedClient.commentOnSumbission(course: course, assignment: assignment, userID: student.id, as: student, comment: "Oops, I meant a different file")
        launch("/courses/\(course.id)/assignments/\(assignment.id)/submissions/\(student.id)", as: student)
        SubmissionDetailsElement.drawerFilesButton.tap()
        SubmissionDetailsElement.drawerCommentsButton.tap()

        XCTAssertTrue(SubmissionCommentsElement.textCell(commentID: comment1.id).isVisible)
        XCTAssertTrue(SubmissionCommentsElement.textCell(commentID: comment2.id).isVisible)
    }
}
