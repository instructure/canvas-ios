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
@testable import Core
@testable import CoreUITests
import TestsFoundation
import XCTest

class TextSubmissionTests: CoreUITestCase {
    func testTextSubmission() {
        mockBaseRequests()
        let course = mock(course: APICourse.make())
        let assignment = APIAssignment.make(submission_types: [ .online_text_entry ])
        mockData(GetAssignmentRequest(courseID: course.id.value, assignmentID: assignment.id.value, include: [.submission]), value: assignment)

        show("/courses/\(course.id)/assignments/\(assignment.id)")
        AssignmentDetails.submitAssignmentButton.tap()
        TextSubmission.submitButton.waitToExist()
        XCTAssertFalse(TextSubmission.submitButton.isEnabled)

        // value:, label:, nor labelContaining: can seem to find the placeholder to show it's ready.
        // app.find(label: "Enter submission").waitToExist()
        sleep(1)

        let webView = app.find(id: "RichContentEditor.webView")
        webView.typeText("     This is rich content.")
        webView.tapAt(.zero).tapAt(.zero)
        app.find(label: "Select All").tap()
        RichContentToolbar.textColorButton.tap()
        RichContentToolbar.blueColorButton.tap()
        RichContentToolbar.italicButton.tap()
        RichContentToolbar.boldButton.tap()
        XCTAssertTrue(TextSubmission.submitButton.isEnabled)

        let create = CreateSubmissionRequest(context: .course("1"), assignmentID: "1", body: nil)
        mockData(create, error: "Bad Network")
        TextSubmission.submitButton.tap()
        app.alerts.buttons.matching(label: "OK").firstElement.tap()

        mockData(create)
        TextSubmission.submitButton.tap()
        TextSubmission.submitButton.waitToVanish()
    }
}
