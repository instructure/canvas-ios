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

class SubmissionDetailsPageTest: StudentTest {
    let page = SubmissionDetailsPage.self

    lazy var course: APICourse = {
        return seedClient.createCourse()
    }()
    lazy var teacher: AuthUser = {
        return createTeacher(in: course)
    }()
    lazy var student: AuthUser = {
        return createStudent(in: course)
    }()

    func testNoSubmission() {
        let dueAt = DateComponents(calendar: Calendar.current, year: 2018, month: 10, day: 31, hour: 22, minute: 0).date!
        let assignment = seedClient.createAssignment(for: course, dueAt: dueAt)
        launch("/courses/\(course.id)/assignments/\(assignment.id)/submissions/\(student.id)", as: student)

        page.assertText(.emptyAssignmentDueBy, equals: "This assignment was due by October 31, 2018 at 10:00 PM")
        page.assertVisible(.emptySubmitButton)
    }

    func testOneSubmission() {
        let assignment = seedClient.createAssignment(for: course)
        let submission = seedClient.submit(assignment: assignment, context: ContextModel(.course, id: course.id), as: student)
        launch("/courses/\(course.id)/assignments/\(assignment.id)/submissions/\(student.id)", as: student)

        page.assertHidden(.emptyView)
        page.assertHidden(.attemptPicker)
        page.assertHidden(.attemptPickerArrow)
        page.assertVisible(.attemptPickerToggle)
        page.assertEnabled(.attemptPickerToggle, false)
        page.assertText(.attemptPickerToggle, equals: DateFormatter.localizedString(from: submission.submitted_at!, dateStyle: .medium, timeStyle: .short))
        page.assertVisible(.onlineTextEntryWebView)
        let body = app?.webViews.staticTexts.firstMatch.label
        XCTAssertEqual(body, submission.body)
    }

    func xtestManySubmissions() { // Too flaky
        let assignment = seedClient.createAssignment(for: course)
        let submission1 = seedClient.submit(assignment: assignment, context: ContextModel(.course, id: course.id), as: student)
        let submission2 = seedClient.resubmit(assignment: assignment, context: ContextModel(.course, id: course.id), as: student, comment: "Oops, I meant this one.")
        launch("/courses/\(course.id)/assignments/\(assignment.id)/submissions/\(student.id)", as: student)

        let date1 = DateFormatter.localizedString(from: submission1.submitted_at!, dateStyle: .medium, timeStyle: .short)
        let date2 = DateFormatter.localizedString(from: submission2.submitted_at!, dateStyle: .medium, timeStyle: .short)

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
        let assignment = seedClient.createAssignment(for: course, submissionTypes: [ .online_upload ], allowedExtensions: [ "pdf" ])
        let file = seedClient.uploadFile(url: Bundle(for: SubmissionDetailsPageTest.self).url(forResource: "empty", withExtension: "pdf")!, for: assignment, as: student)
        let submission = seedClient.submit(assignment: assignment, context: ContextModel(.course, id: course.id), as: student, submissionType: .online_upload, fileIDs: [ file.id.value ])
        let sessionURL = seedClient.createDocViewerSession(for: submission.attachments![0], as: student)
        seedClient.pollForDocViewerMetadata(sessionURL: sessionURL)

        launch("/courses/\(course.id)/assignments/\(assignment.id)/submissions/\(student.id)", as: student)

        PSPDFDoc.waitToExist(.view, timeout: 15.0)
        PSPDFDoc.assertVisible(.view)

        DocViewer.assertVisible(.searchButton)
        DocViewer.tap(.searchButton)
        // PSPDFKit's search view has no accessibility identifiers
        XCTAssertEqual(app?.searchFields.count, 1)
        PSPDFDoc.tap(label: "Done")

        DocViewer.assertVisible(.shareButton)
        // TODO: Test share sheet?
    }

    func xtestPDFAnnotations() {
        let assignment = seedClient.createAssignment(for: course, submissionTypes: [ .online_upload ], allowedExtensions: [ "pdf" ])
        let file = seedClient.uploadFile(url: Bundle(for: SubmissionDetailsPageTest.self).url(forResource: "empty", withExtension: "pdf")!, for: assignment, as: student)
        seedClient.submit(assignment: assignment, context: ContextModel(.course, id: course.id), as: student, submissionType: .online_upload, fileIDs: [ file.id.value ])

        let submission = seedClient.makeRequest(GetSubmissionRequest(context: ContextModel(.course, id: course.id), assignmentID: assignment.id.value, userID: student.id), with: teacher.token)
        let sessionURL = seedClient.createDocViewerSession(for: submission.attachments![0], as: teacher)
        let metadata = seedClient.pollForDocViewerMetadata(sessionURL: sessionURL)
        let point = seedClient.createAnnotation(APIDocViewerAnnotation.make([
            "id": UUID().uuidString,
            "user_name": metadata.annotations.user_name,
            "type": APIDocViewerAnnotationType.text.rawValue,
            "color": DocViewerAnnotationColor.green.rawValue,
            "rect": [ [ 0, (11 * 72) - 240 ], [ 170, (11 * 72) ] ],
        ]), on: sessionURL, as: teacher)
        let comment = seedClient.createAnnotation(APIDocViewerAnnotation.make([
            "id": UUID().uuidString,
            "user_name": metadata.annotations.user_name,
            "type": APIDocViewerAnnotationType.commentReply.rawValue,
            "contents": "Why is the document empty?",
            "inreplyto": point.id,
        ]), on: sessionURL, as: teacher)

        launch("/courses/\(course.id)/assignments/\(assignment.id)/submissions/\(student.id)", as: student)

        PSPDFDoc.waitToExist(.view, timeout: 15.0)

        // 😱 PSPDFAnnotations are not in the accessibility tree
        PSPDFDoc.tap(.view, at: CGPoint(x: 32, y: 32))
        PSPDFDoc.tapCalloutAction("Comments")

        CommentListPage.assertVisible(.tableView)

        CommentListItem.assertVisible(.item(comment.id))
        CommentListItem.assertHidden(.deleteButton(comment.id))

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
        let discussion = seedClient.createGradedDiscussionTopic(
            for: course,
            title: "Discuss this",
            message: "Say it like you mean it",
            pointsPossible: 15.5,
            dueAt: DateComponents(calendar: Calendar.current, year: 2035, month: 1, day: 1, hour: 8).date
        )
        let context = ContextModel(.course, id: course.id)
        let entry = seedClient.createDiscussionEntry(discussion, context: context, message: "First entry", as: student)
        seedClient.createDiscussionEntry(discussion, context: context, message: "Second entry", as: student)

        launch("/courses/\(course.id)/assignments/\(discussion.assignment_id!.value)/submissions/\(student.id)", as: student)

        page.assertHidden(.emptyView)
        page.assertHidden(.attemptPicker)
        page.assertHidden(.attemptPickerArrow)
        page.assertVisible(.attemptPickerToggle)
        page.assertEnabled(.attemptPickerToggle, false)
        page.assertText(.attemptPickerToggle, equals: DateFormatter.localizedString(from: entry.created_at!, dateStyle: .medium, timeStyle: .short))
        page.assertVisible(.discussionWebView)
    }

    func testQuizSubmission() {
        let (quiz, questions) = seedClient.createQuiz(in: course, as: teacher, questions: [
            (question_name: "Question 1", question_text: "Who?", question_type: .short_answer_question, points_possible: 1),
        ])
        seedClient.takeQuiz(quiz, in: course, as: student, answers: [
            questions[0].id: .string("He who shall not be named."),
        ])
        let assignment = seedClient.makeRequest(GetAssignmentsRequest(courseID: course.id), with: student.token).first { $0.quiz_id?.value == quiz.id }
        launch("/courses/\(course.id)/assignments/\(assignment!.id)/submissions/\(student.id)", as: student)

        page.assertHidden(.emptyView)
        page.assertVisible(.onlineQuizWebView)
    }

    func testUrlSubmission() {
        let url = URL(string: "https://www.instructure.com/")!
        let assignment = seedClient.createAssignment(for: course, submissionTypes: [.online_url])
        seedClient.submit(assignment: assignment, context: ContextModel(.course, id: course.id), as: student, submissionType: .online_url, url: url)
        launch("/courses/\(course.id)/assignments/\(assignment.id)/submissions/\(student.id)", as: student)

        page.assertVisible(.urlSubmissionBlurb)
        page.assertVisible(.urlButton)
        page.assertVisible(.urlPreview)

        page.assertHidden(.emptyView)
        page.assertText(.urlSubmissionBlurb, equals: "This submission is a URL to an external page. We've included a snapshot of a what the page looked like when it was submitted.")
    }

    func testExternalToolSubmission() {
        let assignment = seedClient.createAssignment(for: course, submissionTypes: [.external_tool])
        launch("/courses/\(course.id)/assignments/\(assignment.id)/submissions/\(student.id)", as: student)

        page.assertVisible(.externalToolButton)
        page.assertHidden(.emptyView)
    }
}
