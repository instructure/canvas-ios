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

@testable import Core
@testable import CoreUITests
import TestsFoundation
import XCTest

class SubmissionButtonTests: StudentUITestCase {
    lazy var course: APICourse = {
        let course = APICourse.make()
        mockData(GetCourseRequest(courseID: course.id), value: course)
        return course
    }()

    func mockAssignment(_ assignment: APIAssignment) -> APIAssignment {
        mockData(GetAssignmentRequest(courseID: course.id, assignmentID: assignment.id.value, include: [.submission]), value: assignment)
        return assignment
    }

    override func show(_ route: String) {
        super.show(route)
        sleep(1)
    }

    func testOnlineUpload() {
        mockBaseRequests()
        let assignment = mockAssignment(APIAssignment.make(
            submission_types: [ .online_upload ]
        ))
        let target = FileUploadTarget.make()
        mockData(PostFileUploadTargetRequest(
            context: .submission(courseID: course.id.value, assignmentID: assignment.id.value, comment: nil),
            body: .init(name: "", on_duplicate: .overwrite, parent_folder_id: nil, size: 0)
        ), value: target)
        mockData(PostFileUploadRequest(fileURL: URL(string: "data:text/plain,")!, target: target), value: .make())
        mockData(CreateSubmissionRequest(context: ContextModel(.course, id: "1"), assignmentID: "1", body: nil))

        logIn()
        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submitAssignmentButton.tap()
        FilePicker.libraryButton.tap()
        app.find(label: "Camera Roll").tap()
        app.find(labelContaining: "Photo, HDR").tap()
        FilePicker.submitButton.tap()
        FilePicker.submitButton.waitToVanish()
    }
}
