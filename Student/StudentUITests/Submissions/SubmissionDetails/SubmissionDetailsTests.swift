//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import TestsFoundation
import XCTest

class SubmissionDetailsTests: CoreUITestCase {
    lazy var course = mock(course: .make())

    func testNoSubmission() {
        mockBaseRequests()
        let dueAt = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 31, hour: 22, minute: 0).date
        let assignment = mock(assignment: .make(due_at: dueAt))
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            workflow_state: .unsubmitted
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()
        SubmissionDetails.drawerGripper.tap()

        XCTAssertEqual(SubmissionDetails.emptyAssignmentDueBy.label(), "This assignment was due by October 31, 2018 at 10:00 PM")
        XCTAssertTrue(SubmissionDetails.emptySubmitButton.isVisible)
    }

    func testOneSubmission() {
        mockBaseRequests()
        let assignment = mock(assignment: .make())
        let submittedAt = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 31, hour: 22, minute: 0).date!
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            body: "hi",
            submission_type: .online_text_entry,
            submitted_at: submittedAt
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()
        SubmissionDetails.drawerGripper.tap()

        SubmissionDetails.onlineTextEntryWebView.waitToExist(5)
        XCTAssertFalse(SubmissionDetails.emptyView.isVisible)
        XCTAssertFalse(SubmissionDetails.attemptPicker.isVisible)
        XCTAssertTrue(SubmissionDetails.attemptPickerToggle.isVisible)
        XCTAssertFalse(SubmissionDetails.attemptPickerToggle.isEnabled)
        XCTAssertEqual(SubmissionDetails.attemptPickerToggle.label(), DateFormatter.localizedString(from: submittedAt, dateStyle: .medium, timeStyle: .short))
        XCTAssertTrue(SubmissionDetails.onlineTextEntryWebView.isVisible)
        let body = app.webViews.staticTexts.firstMatch.label
        XCTAssertEqual(body, "hi")
    }

    func testManySubmissions() {
        mockBaseRequests()
        let assignment = mock(assignment: .make())
        let submittedAt1 = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 31, hour: 22, minute: 0).date!
        let submittedAt2 = DateComponents(calendar: Calendar.current, year: 2018, month: 11, day: 1, hour: 22, minute: 0).date!
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            attempt: 2,
            body: "two",
            submission_history: [
                APISubmission.make(
                    attempt: 1,
                    body: "one",
                    submission_type: .online_text_entry,
                    submitted_at: submittedAt1
                ),
                APISubmission.make(attempt: 2),
            ],
            submission_type: .online_text_entry,
            submitted_at: submittedAt2
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()
        SubmissionDetails.drawerGripper.tap()

        let date1 = DateFormatter.localizedString(from: submittedAt1, dateStyle: .medium, timeStyle: .short)
        let date2 = DateFormatter.localizedString(from: submittedAt2, dateStyle: .medium, timeStyle: .short)

        XCTAssertFalse(SubmissionDetails.emptyView.isVisible)
        XCTAssertFalse(SubmissionDetails.attemptPicker.isVisible)
        XCTAssertTrue(SubmissionDetails.attemptPickerToggle.isVisible)
        XCTAssertTrue(SubmissionDetails.attemptPickerToggle.isEnabled)
        XCTAssertEqual(SubmissionDetails.attemptPickerToggle.label(), date2)

        SubmissionDetails.attemptPickerToggle.tap()
        XCTAssertTrue(SubmissionDetails.attemptPicker.isVisible)
        SubmissionDetails.attemptPicker.pick(column: 0, value: date1)
        XCTAssertEqual(SubmissionDetails.attemptPickerToggle.label(), date1)
    }

    func testNotGraded() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(submission_types: [.not_graded]))
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value:
                    APISubmission.make(attempt: nil, workflow_state: .unsubmitted
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        XCTAssertFalse(SubmissionDetails.emptyView.isVisible)
    }

    func testGradedButUnsubmitted() {
        mockBaseRequests()
        let assignment = mock(assignment: .make())
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value:
            APISubmission.make(
                attempt: nil,
                grade: "3",
                submission_history: [.make(attempt: nil)],
                workflow_state: .graded
            )
        )

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        XCTAssertFalse(SubmissionDetails.emptyView.isVisible)
    }

    func testPDFSubmission() {
        mockBaseRequests()
        let url = Bundle(for: SubmissionDetailsTests.self).url(forResource: "empty", withExtension: "pdf")
        let previewURL = URL(string: "https://preview.url")!
        let sessionURL = URL(string: "https://doc.viewer/session/123")!
        let downloadURL = URL(string: "https://doc.viewer/session/123/download")!
        let assignment = mock(assignment: .make(submission_types: [ .online_upload ]))
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            attachments: [ APIFile.make(
                mime_class: "pdf",
                preview_url: previewURL
            ), ],
            submission_type: .online_upload
        ))
        mockURL(previewURL, response: HTTPURLResponse(
            url: previewURL, statusCode: 301, httpVersion: nil, headerFields: [
                "Location": "\(sessionURL.absoluteString)/view",
            ]
        ))
        mockData(GetDocViewerMetadataRequest(path: sessionURL.absoluteString), value: APIDocViewerMetadata.make(
            urls: .make(pdf_download: downloadURL)
        ))
        mockEncodableRequest("https://doc.viewer/2018-04-06/sessions/123/annotations", value: APIDocViewerAnnotations(data: []))
        mockURL(downloadURL, data: url.flatMap { try? Data(contentsOf: $0) })

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()
        SubmissionDetails.drawerGripper.tap()

        PSPDFDoc.view.waitToExist(5)
        XCTAssertTrue(PSPDFDoc.view.isVisible)

        XCTAssertTrue(DocViewer.searchButton.isVisible)
        DocViewer.searchButton.tap()
        // PSPDFKit's search view has no accessibility identifiers
        XCTAssertEqual(app.searchFields.count, 1)
        app.find(label: "Done").tap()

        XCTAssertTrue(DocViewer.shareButton.isVisible)
        // TODO: Test share sheet?
    }

    func testPDFAnnotations() {
        mockBaseRequests()
        let url = Bundle(for: SubmissionDetailsTests.self).url(forResource: "empty", withExtension: "pdf")
        let previewURL = URL(string: "https://preview.url")!
        let sessionURL = URL(string: "https://canvas.instructure.com/session/123")!
        let downloadURL = URL(string: "https://canvas.instructure.com/session/123/download")!
        let assignment = mock(assignment: .make(submission_types: [ .online_upload ]))
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            attachments: [ APIFile.make(
                mime_class: "pdf",
                preview_url: previewURL
            ), ],
            submission_type: .online_upload
        ))
        mockURL(previewURL, response: HTTPURLResponse(
            url: previewURL, statusCode: 301, httpVersion: nil, headerFields: [
                "Location": "\(sessionURL.absoluteString)/view",
            ]
        ))
        mockData(GetDocViewerMetadataRequest(path: sessionURL.absoluteString), value: APIDocViewerMetadata.make(
            annotations: .make(permissions: .readwrite),
            urls: .make(pdf_download: downloadURL)
        ))
        mockData(GetDocViewerAnnotationsRequest(sessionID: sessionURL.lastPathComponent), value: APIDocViewerAnnotations(data: [
            APIDocViewerAnnotation.make(
                id: "1",
                user_name: "Student",
                type: .text,
                color: DocViewerAnnotationColor.green.rawValue,
                rect: [ [ 0, (11 * 72) - 240 ], [ 170, (11 * 72) ] ]
            ),
            APIDocViewerAnnotation.make(
                id: "2",
                user_id: "2",
                user_name: "Teacher",
                type: .commentReply,
                contents: "Why is the document empty?",
                inreplyto: "1"
            ),
        ]))
        mockURL(downloadURL, data: url.flatMap { try? Data(contentsOf: $0) })

        // There's a uuid in a request that has no way to be mocked currently
        missingMockBehavior = .allow
        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()
        SubmissionDetails.drawerGripper.tap()

        // 😱 PSPDFAnnotations are not in the accessibility tree
        PSPDFDoc.page.tapAt(CGPoint(x: 32, y: 32))
        app.find(label: "Comments").tap()

        CommentListItem.item("2").waitToExist()
        XCTAssertFalse(CommentListItem.deleteButton("2").isVisible)

        XCTAssertFalse(CommentList.replyButton.isEnabled)
        CommentList.replyTextView.tap()
        CommentList.replyTextView.typeText("I don't know.")
        XCTAssertTrue(CommentList.replyButton.isEnabled)
        CommentList.replyButton.tap()
        XCTAssertFalse(CommentList.replyButton.isEnabled)

        let replyID = String(app.find(label: "Delete comment").id.split(separator: ".")[1])
        XCTAssertTrue(CommentListItem.item(replyID).isVisible)
        XCTAssertTrue(CommentListItem.deleteButton(replyID).isVisible)
        CommentListItem.deleteButton(replyID).tap()
        app.find(label: "Delete").tap()
        CommentListItem.item(replyID).waitToVanish(1)
    }

    func testDiscussionSubmission() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(submission_types: [ .discussion_topic ]))
        let submittedAt = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 31, hour: 22, minute: 0).date!
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            discussion_entries: [
                APIDiscussionEntry.make(id: "1", message: "First entry"),
                APIDiscussionEntry.make(id: "2", message: "Second entry"),
            ],
            preview_url: URL(string: "https://canvas.instructure.com"),
            submission_type: .discussion_topic,
            submitted_at: submittedAt
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()
        SubmissionDetails.drawerGripper.tap()

        XCTAssertFalse(SubmissionDetails.emptyView.isVisible)
        XCTAssertFalse(SubmissionDetails.attemptPicker.isVisible)
        XCTAssertTrue(SubmissionDetails.attemptPickerToggle.isVisible)
        XCTAssertFalse(SubmissionDetails.attemptPickerToggle.isEnabled)
        XCTAssertEqual(SubmissionDetails.attemptPickerToggle.label(), DateFormatter.localizedString(from: submittedAt, dateStyle: .medium, timeStyle: .short))
        XCTAssertTrue(SubmissionDetails.discussionWebView.isVisible)
    }

    func testQuizSubmission() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(
            quiz_id: "1",
            submission_types: [ .online_quiz ]
        ))
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            submission_type: .online_quiz
        ))
        mockData(GetQuizRequest(courseID: "1", quizID: "1"), value: APIQuiz.make())
        mockData(GetQuizSubmissionRequest(courseID: course.id.value, quizID: "1"), value: .init(quiz_submissions: []))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()
        SubmissionDetails.drawerGripper.tap()

        SubmissionDetails.onlineQuizWebView.waitToExist()
        XCTAssertFalse(SubmissionDetails.emptyView.isVisible)
    }

    func testUrlSubmission() {
        mockBaseRequests()
        let url = URL(string: "https://www.instructure.com/")!
        let assignment = mock(assignment: .make(submission_types: [ .online_url ]))
        let attachment = APIFile.make()
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            attachments: [ attachment ],
            submission_type: .online_url,
            url: url
        ))
        mockEncodedData(URLRequest(url: attachment.url!.rawValue), data: Data())

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()
        SubmissionDetails.drawerGripper.tap()

        SubmissionDetails.urlSubmissionBlurb.waitToExist(5)
        XCTAssertTrue(SubmissionDetails.urlSubmissionBlurb.isVisible)
        XCTAssertTrue(SubmissionDetails.urlButton.isVisible)

        XCTAssertFalse(SubmissionDetails.emptyView.isVisible)
        XCTAssertEqual(SubmissionDetails.urlSubmissionBlurb.label(), "This submission is a URL to an external page. We've included a snapshot of a what the page looked like when it was submitted.")
    }

    func testExternalToolSubmission() {
        mockBaseRequests()
        let assignment = mock(assignment: .make(submission_types: [ .external_tool ]))
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make())
        mockData(
            GetSessionlessLaunchURLRequest(
                context: .course(course.id.value),
                id: nil,
                url: nil,
                assignmentID: assignment.id.value,
                moduleItemID: nil,
                launchType: .assessment,
                resourceLinkLookupUUID: nil
            ),
            value: .make()
        )
        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()
        SubmissionDetails.drawerGripper.tap()

        ExternalToolElement.launchButton.waitToExist(5)
        XCTAssertTrue(ExternalToolElement.launchButton.isVisible)
        XCTAssertFalse(SubmissionDetails.emptyView.isVisible)
    }

    func testMediaSubmission() {
        mockBaseRequests()
        let url = Bundle(for: SubmissionDetailsTests.self).url(forResource: "test", withExtension: "m4a")!
        let assignment = mock(assignment: .make(submission_types: [ .media_recording ]))
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            media_comment: APIMediaComment.make(
                media_type: .audio,
                url: url
            ),
            submission_type: .media_recording
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerGripper.tap()
        SubmissionDetails.drawerGripper.tap()

        SubmissionDetails.mediaPlayer.waitToExist()
        XCTAssertTrue(SubmissionDetails.mediaPlayer.isVisible)
    }

    func testRubric() {
        mockBaseRequests()
        let ratings: [APIRubricRating] = [
            APIRubricRating.make(description: "A", id: "1", long_description: "this is A", points: 10),
            APIRubricRating.make(description: "B", id: "2", long_description: "this is B", points: 20),
            APIRubricRating.make(description: "C", id: "3", long_description: "this is C", points: 30),
        ]
        let rubric = APIRubric.make(ratings: ratings)
        let assignment = mock(assignment: .make(id: "2", rubric: [rubric]))
        let submittedAt = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 31, hour: 22, minute: 0).date!
        mockData(GetSubmissionRequest(context: .course(course.id.value), assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            assignment_id: assignment.id.value,
            body: "hi",
            rubric_assessment: ["1": APIRubricAssessment.make()],
            submission_type: .online_text_entry,
            submitted_at: submittedAt
        ))
        mockData(GetCustomColorsRequest(), value: APICustomColors(custom_colors: [
            Context(.course, id: course.id.value).canvasContextID: "#123456",
        ]))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.drawerRubricButton.tap()
        let id: String = rubric.id.value

        XCTAssertFalse(SubmissionDetails.rubricEmptyLabel.isVisible)

        let cell1TitleLabel = SubmissionDetails.rubricCellTitle(id: id)
        XCTAssertEqual(cell1TitleLabel.label(), rubric.description)
        XCTAssertTrue(SubmissionDetails.rubricCellDescButton(id: id).isVisible)

        let button1 = SubmissionDetails.rubricCellRatingButton(rubricID: id, points: ratings[0].points!).waitToExist()
        let button2 = SubmissionDetails.rubricCellRatingButton(rubricID: id, points: ratings[1].points!).waitToExist()
        let button3 = SubmissionDetails.rubricCellRatingButton(rubricID: id, points: ratings[2].points!).waitToExist()
        XCTAssertTrue(button1.isVisible)
        XCTAssertTrue(button2.isVisible)
        XCTAssertTrue(button3.isVisible)

        button1.tap()

        let ratingTitleLabel = SubmissionDetails.rubricCellRatingTitle(id: id)
        let ratingDescLabel = SubmissionDetails.rubricCellRatingDesc(id: id)
        ratingTitleLabel.waitToExist()

        XCTAssertEqual(ratingTitleLabel.label(), ratings[0].description)
        XCTAssertEqual(ratingDescLabel.label(), ratings[0].long_description)

        button2.tap()

        XCTAssertEqual(ratingTitleLabel.label(), ratings[1].description)
        XCTAssertEqual(ratingDescLabel.label(), ratings[1].long_description)

        button3.tap()

        XCTAssertEqual(ratingTitleLabel.label(), ratings[2].description)
        XCTAssertEqual(ratingDescLabel.label(), ratings[2].long_description)

        button3.tap()
        XCTAssertEqual(ratingTitleLabel.label(), "Custom Grade")
        ratingDescLabel.waitToVanish()
    }
}
