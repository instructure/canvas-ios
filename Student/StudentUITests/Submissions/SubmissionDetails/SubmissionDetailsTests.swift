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

class SubmissionDetailsTests: StudentTest {
    let page = SubmissionDetailsPage.self
    let assignmentDetailsPage = AssignmentDetailsPage.self

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
        let assignment = mockAssignment(APIAssignment.make([ "due_at": dueAt ]))
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make([
            "workflow_state": "unsubmitted",
        ]))
        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        page.waitToExist(.emptyAssignmentDueBy, timeout: 5)
        page.assertText(.emptyAssignmentDueBy, equals: "This assignment was due by October 31, 2018 at 10:00 PM")
        page.assertVisible(.emptySubmitButton)
    }

    func testOneSubmission() {
        let assignment = mockAssignment(APIAssignment.make())
        let submittedAt = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 31, hour: 22, minute: 0).date!
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make([
            "body": "hi",
            "submission_type": "online_text_entry",
            "submitted_at": submittedAt,
        ]))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        page.waitToExist(.onlineTextEntryWebView, timeout: 5)
        page.assertHidden(.emptyView)
        page.assertHidden(.attemptPicker)
        page.assertHidden(.attemptPickerArrow)
        page.assertVisible(.attemptPickerToggle)
        page.assertEnabled(.attemptPickerToggle, false)
        page.assertText(.attemptPickerToggle, equals: DateFormatter.localizedString(from: submittedAt, dateStyle: .medium, timeStyle: .short))
        page.assertVisible(.onlineTextEntryWebView)
        let body = app?.webViews.staticTexts.firstMatch.label
        XCTAssertEqual(body, "hi")
    }

    func testManySubmissions() {
        let assignment = mockAssignment(APIAssignment.make())
        let submittedAt1 = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 31, hour: 22, minute: 0).date!
        let submittedAt2 = DateComponents(calendar: Calendar.current, year: 2018, month: 11, day: 1, hour: 22, minute: 0).date!
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make([
            "attempt": 2,
            "submission_history": [
                APISubmission.fixture([
                    "attempt": 1,
                    "body": "one",
                    "submission_type": "online_text_entry",
                    "submitted_at": submittedAt1,
                ]),
                APISubmission.fixture([
                    "attempt": 2,
                    "body": "two",
                    "submission_type": "online_text_entry",
                    "submitted_at": submittedAt2,
                ]),
            ],
        ]))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        let date1 = DateFormatter.localizedString(from: submittedAt1, dateStyle: .medium, timeStyle: .short)
        let date2 = DateFormatter.localizedString(from: submittedAt2, dateStyle: .medium, timeStyle: .short)

        page.assertHidden(.emptyView)
        page.assertHidden(.attemptPicker)
        page.assertVisible(.attemptPickerArrow)
        page.assertVisible(.attemptPickerToggle)
        page.assertEnabled(.attemptPickerToggle)
        page.assertText(.attemptPickerToggle, equals: date2)

        page.tap(.attemptPickerToggle)
        page.assertVisible(.attemptPicker)
        page.pick(.attemptPicker, column: 0, value: date1)
        page.assertText(.attemptPickerToggle, equals: date1)
    }

    func testPDFSubmission() {
        let url = Bundle(for: SubmissionDetailsTests.self).url(forResource: "empty", withExtension: "pdf")
        let previewURL = URL(string: "https://preview.url")!
        let sessionURL = URL(string: "https://doc.viewer/session/123")!
        let downloadURL = URL(string: "https://doc.viewer/session/123/download")!
        let assignment = mockAssignment(APIAssignment.make([ "submission_types": [ "online_upload" ] ]))
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make([
            "submission_type": "online_upload",
            "attachments": [ APIFile.fixture([
                "preview_url": previewURL.absoluteString,
            ]), ],
        ]))
        mockDataRequest(URLRequest(url: previewURL), response: HTTPURLResponse(
            url: previewURL, statusCode: 301, httpVersion: nil, headerFields: [
                "Location": "\(sessionURL.absoluteString)/view",
            ]
        ))
        mockData(GetDocViewerMetadataRequest(path: sessionURL.absoluteString), value: APIDocViewerMetadata.make([
            "urls": APIDocViewerURLsMetadata.fixture([ "pdf_download": downloadURL.absoluteString ]),
        ]))
        mockDownload(downloadURL, data: url)

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        PSPDFDoc.waitToExist(.view, timeout: 5)
        PSPDFDoc.assertVisible(.view)

        DocViewer.assertVisible(.searchButton)
        DocViewer.tap(.searchButton)
        // PSPDFKit's search view has no accessibility identifiers
        XCTAssertEqual(app?.searchFields.count, 1)
        PSPDFDoc.tap(label: "Done")

        DocViewer.assertVisible(.shareButton)
        // TODO: Test share sheet?
    }

    func testPDFAnnotations() {
        let url = Bundle(for: SubmissionDetailsTests.self).url(forResource: "empty", withExtension: "pdf")
        let previewURL = URL(string: "https://preview.url")!
        let sessionURL = URL(string: "https://canvas.instructure.com/session/123")!
        let downloadURL = URL(string: "https://canvas.instructure.com/session/123/download")!
        let assignment = mockAssignment(APIAssignment.make([ "submission_types": [ "online_upload" ] ]))
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make([
            "submission_type": "online_upload",
            "attachments": [ APIFile.fixture([
                "preview_url": previewURL.absoluteString,
            ]), ],
        ]))
        mockDataRequest(URLRequest(url: previewURL), response: HTTPURLResponse(
            url: previewURL, statusCode: 301, httpVersion: nil, headerFields: [
                "Location": "\(sessionURL.absoluteString)/view",
            ]
        ))
        mockData(GetDocViewerMetadataRequest(path: sessionURL.absoluteString), value: APIDocViewerMetadata.make([
            "annotations": APIDocViewerAnnotationsMetadata.fixture([
                "permissions": "readwrite",
            ]),
            "urls": APIDocViewerURLsMetadata.fixture([ "pdf_download": downloadURL.absoluteString ]),
        ]))
        mockData(GetDocViewerAnnotationsRequest(sessionID: sessionURL.lastPathComponent), value: APIDocViewerAnnotations(data: [
            APIDocViewerAnnotation.make([
                "id": "1",
                "user_name": "Student",
                "type": APIDocViewerAnnotationType.text.rawValue,
                "color": DocViewerAnnotationColor.green.rawValue,
                "rect": [ [ 0, (11 * 72) - 240 ], [ 170, (11 * 72) ] ],
            ]),
            APIDocViewerAnnotation.make([
                "id": "2",
                "user_id": "2",
                "user_name": "Teacher",
                "type": APIDocViewerAnnotationType.commentReply.rawValue,
                "contents": "Why is the document empty?",
                "inreplyto": "1",
            ]),
        ]))
        mockDownload(downloadURL, data: url)

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        PSPDFDoc.waitToExist(.view, timeout: 5)

        // 😱 PSPDFAnnotations are not in the accessibility tree
        PSPDFDoc.tap(.view, at: CGPoint(x: 32, y: 32))
        PSPDFDoc.tapCalloutAction("Comments")

        CommentListPage.assertVisible(.tableView)

        CommentListItem.assertVisible(.item("2"))
        CommentListItem.assertHidden(.deleteButton("2"))

        CommentListPage.assertEnabled(.replyButton, false)
        CommentListPage.typeText("I don't know.", in: .replyTextView)
        CommentListPage.assertEnabled(.replyButton)
        CommentListPage.tap(.replyButton)
        CommentListPage.assertEnabled(.replyButton, false)

        let replyID = String(CommentListPage.findIdentifier(for: "Delete comment").split(separator: ".")[1])
        CommentListItem.assertVisible(.item(replyID))
        CommentListItem.assertEnabled(.deleteButton(replyID))
        CommentListItem.tap(.deleteButton(replyID))
        CommentListPage.assertAlertExists()
        CommentListPage.tapAlertAction("Delete")
        CommentListItem.assertHidden(.item(replyID))
    }

    func testDiscussionSubmission() {
        let assignment = mockAssignment(APIAssignment.make([ "submission_types": [ "discussion_topic" ] ]))
        let submittedAt = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 31, hour: 22, minute: 0).date!
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make([
            "submission_type": "discussion_topic",
            "submitted_at": submittedAt,
            "preview_url": "https://canvas.instructure.com",
            "discussion_entries": [
                APIDiscussionEntry.fixture([ "id": "1", "message": "First entry" ]),
                APIDiscussionEntry.fixture([ "id": "2", "message": "Second entry" ]),
            ],
        ]))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        page.assertHidden(.emptyView)
        page.assertHidden(.attemptPicker)
        page.assertHidden(.attemptPickerArrow)
        page.assertVisible(.attemptPickerToggle)
        page.assertEnabled(.attemptPickerToggle, false)
        page.assertText(.attemptPickerToggle, equals: DateFormatter.localizedString(from: submittedAt, dateStyle: .medium, timeStyle: .short))
        page.assertVisible(.discussionWebView)
    }

    func testQuizSubmission() {
        let assignment = mockAssignment(APIAssignment.make([
            "submission_types": [ "online_quiz" ],
            "quiz_id": "1",
        ]))
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make([
            "submission_type": "online_quiz",
        ]))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        page.assertHidden(.emptyView)
        page.assertVisible(.onlineQuizWebView)
    }

    func testUrlSubmission() {
        let url = URL(string: "https://www.instructure.com/")!
        let assignment = mockAssignment(APIAssignment.make([ "submission_types": [ "online_url" ] ]))
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make([
            "submission_type": "online_url",
            "url": url.absoluteString,
            "attachments": [ APIFile.fixture() ],
        ]))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        page.waitToExist(.urlSubmissionBlurb, timeout: 5)
        page.assertVisible(.urlSubmissionBlurb)
        page.assertVisible(.urlButton)
        page.assertVisible(.urlPreview)

        page.assertHidden(.emptyView)
        page.assertText(.urlSubmissionBlurb, equals: "This submission is a URL to an external page. We've included a snapshot of a what the page looked like when it was submitted.")
    }

    func testExternalToolSubmission() {
        let assignment = mockAssignment(APIAssignment.make([ "submission_types": [ "external_tool" ] ]))
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make())

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")

        page.waitToExist(.externalToolButton, timeout: 5)
        page.assertVisible(.externalToolButton)
        page.assertHidden(.emptyView)
    }

    func testMediaSubmission() {
        let url = Bundle(for: SubmissionDetailsTests.self).url(forResource: "test", withExtension: "m4a")!
        let assignment = mockAssignment(APIAssignment.make([ "submission_types": [ "media_recording" ] ]))
        mockData(GetSubmissionRequest(context: course, assignmentID: assignment.id.value, userID: "1"), value: APISubmission.make([
            "submission_type": "media_recording",
            "media_comment": APIMediaComment.fixture([
                "media_type": "audio",
                "url": url.absoluteString,
            ]),
        ]))

        show("/courses/\(course.id)/assignments/\(assignment.id)/submissions/1")
        page.waitToExist(.mediaPlayer, timeout: 2)
        page.assertVisible(.mediaPlayer)
    }
}
