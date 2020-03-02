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
@testable import CoreUITests

class SpeedGraderTests: TeacherUITestCase {
    let mockHelper = SpeedGraderUIMocks()

    func testSubmissionCommentAttachments() {
        mockBaseRequests()
        mockData(GetAssignmentRequest(courseID: "1", assignmentID: "1", allDates: true, include: [.overrides]), value: .make(id: "1"))
        mockData(GetGroupsRequest(context: ContextModel(.course, id: "1")), value: [])
        let attachment = APIFile.make(
            id: "1",
            display_name: "screenshot.png",
            url: UIImage.icon(.paperclip).asDataUrl!
        )
        mockURL(attachment.url!.rawValue, data: UIImage.icon(.paperclip).pngData())
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
        SpeedGrader.dismissTutorial()
        app.find(id: "speedgrader.segment-control").waitToExist()
        app.segmentedControls.buttons["Comments"].tap()
        app.find(id: "CommentAttachment-1").tap()
        app.find(id: "AttachmentView.image").waitToExist()
        app.find(id: "attachment-view.share-btn").waitToExist()
        app.find(label: "Attachment").waitToExist()
        NavBar.dismissButton.tap()
        app.find(id: "AttachmentView.image").waitToVanish()
    }

    func testNavigateToSpeedGrader() {
        mockHelper.mock(for: self)
        logIn()
        Dashboard.courseCard(id: "1").tap()
        CourseNavigation.assignments.tap()
        AssignmentsList.assignment(id: "1").tap()
        AssignmentDetails.viewAllSubmissionsButton.tap()
        SubmissionsList.row(contextID: "1").tap()
        SpeedGrader.dismissTutorial()
    }

    func inProgressTestQuizLoadsWebView() {
        mockHelper.mock(for: self)

        let quiz = APIQuiz.make(quiz_type: .assignment)
        let quizSubmissions: [APIQuizSubmission] = [
            .make(quiz_id: quiz.id, workflow_state: .complete),
        ]

        mockData(ListQuizzesRequest(courseID: "1"), value: [quiz])
        mockData(GetQuizRequest(courseID: "1", quizID: quiz.id.value), value: quiz)
        mockData(GetAllQuizSubmissionsRequest(courseID: "1", quizID: quiz.id.value, includes: [.submission], perPage: 99),
                 value: .init(quiz_submissions: quizSubmissions))
        mockData(GetAllQuizSubmissionsRequest(courseID: "1", quizID: quiz.id.value),
                 value: .init(quiz_submissions: quizSubmissions))
        mockData(GetCourseSectionsRequest(courseID: "1", include: [.total_students], perPage: 99),
                 value: [.make()])

        logIn()
        Dashboard.courseCard(id: "1").tap()
        CourseNavigation.quizzes.tap()

        app.find(id: "quiz-row-0").tap()
        app.find(id: "quizzes.details.viewAllSubmissionsRow").tap()
    }
}
