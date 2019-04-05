//
// Copyright (C) 2018-present Instructure, Inc.
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
@testable import Core
import TestsFoundation

class FilePickerPageTests: StudentTest {
    let page = FilePickerPage.self
}

class SubmissionFilePickerPageTests: FilePickerPageTests {
    func testEmptyState() {
        let assignment = APIAssignment.make()
        mockData(GetAssignmentRequest(courseID: "1", assignmentID: "1", include: []), value: assignment)

        show("/courses/\(assignment.course_id)/assignments/\(assignment.id)/fileupload")
        page.assertExists(.emptyView)
        page.assertExists(.cameraButton)
        page.assertExists(.libraryButton)
        page.assertExists(.filesButton)
    }

    func testHidesCameraAndLibraryIfNotAllowed() {
        let assignment = APIAssignment.make([
            "submission_types": [ "online_upload" ],
            "allowed_extensions": [ "txt" ],
        ])
        mockData(GetAssignmentRequest(courseID: "1", assignmentID: "1", include: []), value: assignment)

        show("/courses/\(assignment.course_id)/assignments/\(assignment.id)/fileupload")
        page.assertExists(.filesButton)
        page.assertHidden(.cameraButton)
        page.assertHidden(.libraryButton)
    }

    func testCapturePhoto() {
        #if !(targetEnvironment(simulator))
        let assignment = APIAssignment.make([
            "submission_types": [ "online_upload" ],
        ])
        mockData(GetAssignmentRequest(courseID: "1", assignmentID: "1", include: []), value: assignment)
        show("/courses/\(assignment.course_id)/assignments/\(assignment.id)/fileupload")
        page.tap(.cameraButton)
        capturePhoto()
        FilePickerListItem.assertExists(.item("0"))
        #endif
    }
}
