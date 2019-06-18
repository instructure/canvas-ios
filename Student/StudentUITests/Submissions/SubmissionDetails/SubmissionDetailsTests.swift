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
import XCTest

class SubmissionDetailsTests: StudentUITestCase {
    lazy var course: APICourse = {
        let course = APICourse.make()
        mockData(GetCourseRequest(courseID: course.id), value: course)
        return course
    }()

    func mockAssignment(_ assignment: APIAssignment) -> APIAssignment {
        mockData(GetAssignmentRequest(courseID: course.id, assignmentID: assignment.id.value, include: []), value: assignment)
        return assignment
    }

    func testNoSubmission() {
        let dueAt = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 31, hour: 22, minute: 0).date
        let assignment = mockAssignment(APIAssignment.make(due_at: dueAt))
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            workflow_state: .unsubmitted
        ))
        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        SubmissionDetails.emptyAssignmentDueBy.waitToExist(5)
        XCTAssertEqual(SubmissionDetails.emptyAssignmentDueBy.label, "This assignment was due by October 31, 2018 at 10:00 PM")
        XCTAssertTrue(SubmissionDetails.emptySubmitButton.isVisible)
    }

    func testOneSubmission() {
        let assignment = mockAssignment(APIAssignment.make())
        let submittedAt = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 31, hour: 22, minute: 0).date!
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            body: "hi",
            submission_type: .online_text_entry,
            submitted_at: submittedAt
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        SubmissionDetails.onlineTextEntryWebView.waitToExist(5)
        XCTAssertFalse(SubmissionDetails.emptyView.isVisible)
        XCTAssertFalse(SubmissionDetails.attemptPicker.isVisible)
        XCTAssertTrue(SubmissionDetails.attemptPickerToggle.isVisible)
        XCTAssertFalse(SubmissionDetails.attemptPickerToggle.isEnabled)
        XCTAssertEqual(SubmissionDetails.attemptPickerToggle.label, DateFormatter.localizedString(from: submittedAt, dateStyle: .medium, timeStyle: .short))
        XCTAssertTrue(SubmissionDetails.onlineTextEntryWebView.isVisible)
        let body = app.webViews.staticTexts.firstMatch.label
        XCTAssertEqual(body, "hi")
    }

    func testManySubmissions() {
        let assignment = mockAssignment(APIAssignment.make())
        let submittedAt1 = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 31, hour: 22, minute: 0).date!
        let submittedAt2 = DateComponents(calendar: Calendar.current, year: 2018, month: 11, day: 1, hour: 22, minute: 0).date!
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            attempt: 2,
            submission_history: [
                APISubmission.make(
                    body: "one",
                    submission_type: .online_text_entry,
                    submitted_at: submittedAt1,
                    attempt: 1
                ),
                APISubmission.make(
                    body: "two",
                    submission_type: .online_text_entry,
                    submitted_at: submittedAt2,
                    attempt: 2
                ),
            ]
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        let date1 = DateFormatter.localizedString(from: submittedAt1, dateStyle: .medium, timeStyle: .short)
        let date2 = DateFormatter.localizedString(from: submittedAt2, dateStyle: .medium, timeStyle: .short)

        XCTAssertFalse(SubmissionDetails.emptyView.isVisible)
        XCTAssertFalse(SubmissionDetails.attemptPicker.isVisible)
        XCTAssertTrue(SubmissionDetails.attemptPickerToggle.isVisible)
        XCTAssertTrue(SubmissionDetails.attemptPickerToggle.isEnabled)
        XCTAssertEqual(SubmissionDetails.attemptPickerToggle.label, date2)

        SubmissionDetails.attemptPickerToggle.tap()
        XCTAssertTrue(SubmissionDetails.attemptPicker.isVisible)
        SubmissionDetails.attemptPicker.pick(column: 0, value: date1)
        XCTAssertEqual(SubmissionDetails.attemptPickerToggle.label, date1)
    }

    func testPDFSubmission() {
        let url = Bundle(for: SubmissionDetailsTests.self).url(forResource: "empty", withExtension: "pdf")
        let previewURL = URL(string: "https://preview.url")!
        let sessionURL = URL(string: "https://doc.viewer/session/123")!
        let downloadURL = URL(string: "https://doc.viewer/session/123/download")!
        let assignment = mockAssignment(APIAssignment.make(submission_types: [ .online_upload ]))
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            submission_type: .online_upload,
            attachments: [ APIFile.make(
                preview_url: previewURL
            ), ]
        ))
        mockDataRequest(URLRequest(url: previewURL), response: HTTPURLResponse(
            url: previewURL, statusCode: 301, httpVersion: nil, headerFields: [
                "Location": "\(sessionURL.absoluteString)/view",
            ]
        ))
        mockData(GetDocViewerMetadataRequest(path: sessionURL.absoluteString), value: APIDocViewerMetadata.make(
            urls: .make(pdf_download: downloadURL)
        ))
        mockDownload(downloadURL, data: url)

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

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
        let url = Bundle(for: SubmissionDetailsTests.self).url(forResource: "empty", withExtension: "pdf")
        let previewURL = URL(string: "https://preview.url")!
        let sessionURL = URL(string: "https://canvas.instructure.com/session/123")!
        let downloadURL = URL(string: "https://canvas.instructure.com/session/123/download")!
        let assignment = mockAssignment(APIAssignment.make(submission_types: [ .online_upload ]))
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            submission_type: .online_upload,
            attachments: [ APIFile.make(
                preview_url: previewURL
            ), ]
        ))
        mockDataRequest(URLRequest(url: previewURL), response: HTTPURLResponse(
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
        mockDownload(downloadURL, data: url)

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

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
        let assignment = mockAssignment(APIAssignment.make(submission_types: [ .discussion_topic ]))
        let submittedAt = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 31, hour: 22, minute: 0).date!
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            submission_type: .discussion_topic,
            submitted_at: submittedAt,
            discussion_entries: [
                APIDiscussionEntry.make(id: "1", message: "First entry"),
                APIDiscussionEntry.make(id: "2", message: "Second entry"),
            ],
            preview_url: URL(string: "https://canvas.instructure.com")
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        XCTAssertFalse(SubmissionDetails.emptyView.isVisible)
        XCTAssertFalse(SubmissionDetails.attemptPicker.isVisible)
        XCTAssertTrue(SubmissionDetails.attemptPickerToggle.isVisible)
        XCTAssertFalse(SubmissionDetails.attemptPickerToggle.isEnabled)
        XCTAssertEqual(SubmissionDetails.attemptPickerToggle.label, DateFormatter.localizedString(from: submittedAt, dateStyle: .medium, timeStyle: .short))
        XCTAssertTrue(SubmissionDetails.discussionWebView.isVisible)
    }

    func testQuizSubmission() {
        let assignment = mockAssignment(APIAssignment.make(
            quiz_id: "1",
            submission_types: [ .online_quiz ]
        ))
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            submission_type: .online_quiz
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        SubmissionDetails.onlineQuizWebView.waitToExist()
        XCTAssertFalse(SubmissionDetails.emptyView.isVisible)
    }

    func testUrlSubmission() {
        let url = URL(string: "https://www.instructure.com/")!
        let assignment = mockAssignment(APIAssignment.make(submission_types: [ .online_url ]))
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            submission_type: .online_url,
            attachments: [ APIFile.make() ],
            url: url
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        SubmissionDetails.urlSubmissionBlurb.waitToExist(5)
        XCTAssertTrue(SubmissionDetails.urlSubmissionBlurb.isVisible)
        XCTAssertTrue(SubmissionDetails.urlButton.isVisible)

        XCTAssertFalse(SubmissionDetails.emptyView.isVisible)
        XCTAssertEqual(SubmissionDetails.urlSubmissionBlurb.label, "This submission is a URL to an external page. We've included a snapshot of a what the page looked like when it was submitted.")
    }

    func testExternalToolSubmission() {
        let assignment = mockAssignment(APIAssignment.make(submission_types: [ .external_tool ]))
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make())

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        SubmissionDetails.externalToolButton.waitToExist(5)
        XCTAssertTrue(SubmissionDetails.externalToolButton.isVisible)
        XCTAssertFalse(SubmissionDetails.emptyView.isVisible)
    }

    func testMediaSubmission() {
        let url = Bundle(for: SubmissionDetailsTests.self).url(forResource: "test", withExtension: "m4a")!
        let assignment = mockAssignment(APIAssignment.make(submission_types: [ .media_recording ]))
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make(
            submission_type: .media_recording,
            media_comment: APIMediaComment.make(
                media_type: .audio,
                url: url
            )
        ))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        SubmissionDetails.mediaPlayer.waitToExist(2)
        XCTAssertTrue(SubmissionDetails.mediaPlayer.isVisible)
    }
}
