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

import XCTest
import TestsFoundation
@testable import Core
import CoreUITests

class SpeedGraderTests: TeacherUITestCase {
    override var user: UITestUser? { nil }

    func testSubmissionCommentAttachments() {
        mockBaseRequests()
        mockData(GetAssignmentRequest(courseID: "1", assignmentID: "1", allDates: true, include: [.overrides]), value: .make(id: "1"))
        mockData(GetGroupsRequest(context: ContextModel(.course, id: "1")), value: [])
        let image = UIImage.icon(.paperclip)
        let attachment = APIFile.make(
            id: "1",
            display_name: "screenshot.png",
            url: URL(string: "data:image/png;base64,\(image.pngData()!.base64EncodedString())")!
        )
        mockURL(attachment.url, data: UIImage.icon(.paperclip).pngData())
        mockData(
            GetSubmissionsRequest(
                context: ContextModel(.course, id: "1"),
                assignmentID: "1",
                grouped: true,
                include: [.group, .rubric_assessment, .submission_comments, .submission_history, .total_scores, .user]
            ),
            value: [.make(user_id: "1", submission_comments: [.make(attachments: [attachment])])]
        )
        mockData(
            GetSubmissionsRequest(
                context: ContextModel(.course, id: "1"),
                assignmentID: "1",
                grouped: false,
                include: [.group, .rubric_assessment, .submission_comments, .submission_history, .total_scores, .user]
            ),
            value: [.make(user_id: "1", submission_comments: [.make(attachments: [attachment])])]
        )
        mockEncodableRequest("courses/1/enrollments?include[]=avatar_url", value: [
            APIEnrollment.make(user_id: "1", user: .make(id: "1")),
        ])
        mockEncodableRequest("courses/1/assignments/1/submission_summary", value: APISubmission.make())
        show("/courses/1/assignments/1/submissions/1")
        dismissTutorial()
        app.find(id: "speedgrader.segment-control").waitToExist()
        app.segmentedControls.buttons["Comments"].tap()
        app.find(id: "CommentAttachment-1").tap()
        app.find(id: "AttachmentView.image").waitToExist()
        app.find(id: "attachment-view.share-btn").waitToExist()
        app.find(label: "Attachment").waitToExist()
        NavBar.dismissButton.tap()
        app.find(id: "AttachmentView.image").waitToVanish()
    }

    func dismissTutorial() {
        let button = app.find(id: "tutorial.button-swipe-tutorial")
        let exists = button.rawElement.waitForExistence(timeout: 3)
        if (exists) {
            button.tap()
            button.waitToVanish()
        }
    }
}
