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
    lazy var course: APICourse = seedClient.createCourse()
    lazy var student: AuthUser = createStudent(in: course)
    lazy var assignment: APIAssignment = seedClient.createAssignment(for: course, submissionTypes: [ .online_upload ], allowedExtensions: [ "pdf" ])

    func testFilesList() {
        let file1 = seedClient.uploadFile(url: Bundle(for: SubmissionFilesTests.self).url(forResource: "empty", withExtension: "pdf")!, named: "File 1", for: assignment, as: student)
        let file2 = seedClient.uploadFile(url: Bundle(for: SubmissionFilesTests.self).url(forResource: "empty", withExtension: "pdf")!, named: "File 2", for: assignment, as: student)
        seedClient.submit(
            assignment: assignment,
            context: ContextModel(.course, id: course.id),
            as: student,
            submissionType: .online_upload,
            fileIDs: [ file1.id.value, file2.id.value ]
        )
        launch("/courses/\(course.id)/assignments/\(assignment.id)/submissions/\(student.id)", as: student)
        SubmissionDetailsElement.drawerFilesButton.tap()

        XCTAssertTrue(SubmissionFilesElement.cell(fileID: file1.id.value).isVisible)
        XCTAssertTrue(SubmissionFilesElement.checkView(fileID: file1.id.value).isVisible)
        XCTAssertTrue(SubmissionFilesElement.cell(fileID: file2.id.value).isVisible)
        XCTAssertFalse(SubmissionFilesElement.checkView(fileID: file2.id.value).isVisible)

        SubmissionFilesElement.cell(fileID: file2.id.value).tap()

        XCTAssertFalse(SubmissionFilesElement.checkView(fileID: file1.id.value).isVisible)
        XCTAssertTrue(SubmissionFilesElement.checkView(fileID: file2.id.value).isVisible)
    }
}
