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

import XCTest
@testable import Student
@testable import Core
import TestsFoundation
import AVKit

class SubmissionDetailsView: UIViewController, SubmissionDetailsViewProtocol {
    func showAlert(title: String?, message: String?) {}

    var color: UIColor?
    var titleSubtitleView = TitleSubtitleView()

    var didEmbed = false
    var embedded: UIViewController?
    func embed(_ controller: UIViewController?) {
        didEmbed = true
        embedded = controller
    }

    var didEmbedInDrawer = false
    var embeddedInDrawer: UIViewController?
    func embedInDrawer(_ controller: UIViewController?) {
        didEmbedInDrawer = true
        embeddedInDrawer = controller
    }

    var didReload = false
    func reload() {
        didReload = true
    }

    var didReloadNavbar = false
    func reloadNavBar() {
        didReloadNavbar = true
    }

    var presented: UIViewController?
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        presented = viewControllerToPresent
    }
}

class SubmissionDetailsPresenterTests: StudentTestCase {
    var presenter: SubmissionDetailsPresenter!
    var view: SubmissionDetailsView!
    var viewController: SubmissionDetailsViewController!

    override func setUp() {
        super.setUp()

        view = SubmissionDetailsView()
        presenter = SubmissionDetailsPresenter(env: env, view: view, context: .course("1"), assignmentID: "1", userID: "1")
        viewController = SubmissionDetailsViewController.loadFromStoryboard()
        viewController.presenter = presenter
    }

    func testViewIsReady() {
        presenter.viewIsReady()
        XCTAssertTrue(view.didReloadNavbar)
    }

    func testUpdate() {
        Submission.make(from: .make(assignment_id: "1", attempt: 1, user_id: "1"))
        Submission.make(from: .make(assignment_id: "1", attachments: [ .make(id: "1"), .make(id: "2") ], attempt: 2, user_id: "1"))
        presenter.viewIsReady()
        XCTAssertTrue(view.didEmbed)
        XCTAssertTrue(view.didEmbedInDrawer)

        view.didEmbed = false
        view.didEmbedInDrawer = false
        view.didReload = false
        view.didReloadNavbar = false
        presenter.selectedAttempt = 7
        presenter.selectedFileID = "7"
        presenter.update()
        XCTAssertEqual(presenter.selectedAttempt, 2)
        XCTAssertEqual(presenter.selectedFileID, "1")
        XCTAssertFalse(view.didEmbed)
        XCTAssertFalse(view.didEmbedInDrawer)
        XCTAssertTrue(view.didReload)
        XCTAssertTrue(view.didReloadNavbar)

        view.didEmbed = false
        view.didEmbedInDrawer = false
        view.didReload = false
        view.didReloadNavbar = false
        presenter.update()
        XCTAssertFalse(view.didEmbed)
        XCTAssertFalse(view.didEmbedInDrawer)
        XCTAssertTrue(view.didReload)
        XCTAssertTrue(view.didReloadNavbar)
    }

    func testSelectAttempt() {
        Submission.make(from: .make(assignment_id: "1", attachments: [ .make(id: "1") ], attempt: 1, user_id: "1"))
        Submission.make(from: .make(assignment_id: "1", attempt: 2, user_id: "1"))
        presenter.viewIsReady()
        presenter.select(attempt: 1)
        XCTAssertEqual(presenter.selectedAttempt, 1)
        XCTAssertEqual(presenter.selectedFileID, "1")
    }

    func testSelectFileID() {
        Submission.make(from: .make(assignment_id: "1", attempt: 1, user_id: "1"))
        Submission.make(from: .make(assignment_id: "1", attachments: [ .make(id: "1"), .make(id: "2") ], attempt: 2, user_id: "1"))
        presenter.viewIsReady()
        presenter.select(fileID: "2")
        XCTAssertEqual(presenter.selectedFileID, "2")
        presenter.select(fileID: "bogus")
        XCTAssertEqual(presenter.selectedFileID, "1")
    }

    func testSelectDrawerTabComments() {
        Submission.make(from: .make(assignment_id: "1", attachments: [ .make(id: "1"), .make(id: "2") ], attempt: 1, user_id: "1"))
        Submission.make(from: .make(assignment_id: "1", attachments: [ .make(id: "3"), .make(id: "4") ], attempt: 2, user_id: "1"))
        presenter.viewIsReady()
        presenter.select(drawerTab: nil)
        XCTAssertEqual(presenter.selectedDrawerTab, .comments)
        XCTAssert(view.embeddedInDrawer is SubmissionCommentsViewController)

        // does not reembed when attempt changes
        view.embeddedInDrawer = nil
        presenter.select(attempt: 1)
        XCTAssertNil(view.embeddedInDrawer)
    }

    func testSelectDrawerTabFiles() {
        Submission.make(from: .make(assignment_id: "1", attachments: [ .make(id: "1"), .make(id: "2") ], attempt: 1, user_id: "1"))
        Submission.make(from: .make(assignment_id: "1", attachments: [ .make(id: "3"), .make(id: "4") ], attempt: 2, user_id: "1"))
        presenter.viewIsReady()
        presenter.select(drawerTab: .files)
        XCTAssertEqual(presenter.selectedDrawerTab, .files)
        XCTAssert(view.embeddedInDrawer is SubmissionFilesViewController)

        // reembeds when attempt changes
        view.embeddedInDrawer = nil
        presenter.select(attempt: 1)
        XCTAssert(view.embeddedInDrawer is SubmissionFilesViewController)
    }

    func testSelectDrawerTabRubric() {
        Submission.make(from: .make(assignment_id: "1", attachments: [ .make(id: "1"), .make(id: "2") ], attempt: 1, user_id: "1"))
        presenter.viewIsReady()
        presenter.select(drawerTab: .rubric)
        XCTAssertEqual(presenter.selectedDrawerTab, .rubric)
        XCTAssert(view.embeddedInDrawer is RubricViewController)
    }

    func testEmbedExternalTool() {
        Assignment.make(from: .make(submission_types: [ .external_tool ]))
        Submission.make(from: .make(submission_type: .external_tool))
        presenter.viewIsReady()

        XCTAssert(view.embedded is LTIViewController)
    }

    func testEmbedExternalToolOnlineUploadWithAttachment() {
        Assignment.make(from: .make(submission_types: [ .external_tool ]))
        Submission.make(from: .make(
            attachments: [ .make(mime_class: "doc", preview_url: URL(string: "/preview")) ], submission_type: .online_upload
        ))
        presenter.viewIsReady()

        XCTAssert(view.embedded is DocViewerViewController)
    }

    func testEmbedQuiz() throws {
        Assignment.make(from: .make(quiz_id: "1"))
        Submission.make(from: .make(submission_type: .online_quiz))
        presenter.viewIsReady()

        let embedded = try XCTUnwrap(view.embedded as? CoreWebViewController)
        XCTAssertEqual(embedded.webView.accessibilityIdentifier, "SubmissionDetails.onlineQuizWebView")
    }

    func testEmbedTextEntry() throws {
        Assignment.make()
        Submission.make(from: .make(submission_type: .online_text_entry))
        presenter.viewIsReady()

        let embedded = try XCTUnwrap(view.embedded as? CoreWebViewController)
        XCTAssertEqual(embedded.webView.accessibilityIdentifier, "SubmissionDetails.onlineTextEntryWebView")
    }

    func testEmbedUpload() {
        Assignment.make()
        Submission.make(from: .make(
            attachments: [ .make(mime_class: "doc", preview_url: URL(string: "/preview")) ], submission_type: .online_upload
        ))
        presenter.viewIsReady()

        XCTAssert(view.embedded is DocViewerViewController)
    }

    func testEmbedUploadVideo() {
        Assignment.make()
        Submission.make(from: .make(
            attachments: [ .make(mime_class: "video") ],
            submission_type: .online_upload
        ))
        presenter.viewIsReady()

        XCTAssert(view.embedded is AVPlayerViewController)
    }

    func testEmbedUploadOther() {
        Assignment.make()
        Submission.make(from: .make(
            attachments: [ .make(mime_class: "file") ],
            submission_type: .online_upload
        ))
        presenter.viewIsReady()

        XCTAssert(view.embedded is CoreWebViewController)
    }

    func testEmbedUploadHeic() {
        Assignment.make()
        Submission.make(from: .make(
            attachments: [ .make(contentType: "image/heic", mime_class: "file") ],
            submission_type: .online_upload
        ))
        presenter.viewIsReady()

        XCTAssertNotNil(view.embedded)
        XCTAssert(view.embedded?.view is UIImageView)
    }

    func testEmbedDiscussion() throws {
        Assignment.make()
        Submission.make(from: .make(preview_url: URL(string: "preview"), submission_type: .discussion_topic))
        presenter.viewIsReady()

        let embedded = try XCTUnwrap(view.embedded as? CoreWebViewController)
        XCTAssertEqual(embedded.webView.accessibilityIdentifier, "SubmissionDetails.discussionWebView")
    }

    func testEmbedURL() {
        Assignment.make()
        Submission.make(from: .make(submission_type: .online_url))
        presenter.viewIsReady()

        XCTAssert(view.embedded is UrlSubmissionContentViewController)
    }

    func testEmbedMediaSubmission() {
        Assignment.make()
        Submission.make(from: .make(media_comment: .make(), submission_type: .media_recording ))
        presenter.viewIsReady()

        XCTAssert(view.embedded is AVPlayerViewController)
    }

    func testEmbedArc() throws {
        Assignment.make()
        let submission = Submission.make(from: .make(
            external_tool_url: .make(),
            submission_type: .basic_lti_launch
        ))
        presenter.viewIsReady()

        let ltiController = try XCTUnwrap(view.embedded as? LTIViewController)
        XCTAssertEqual(ltiController.tools.url, submission.externalToolURL!)
    }

    func testEmbedStudentAnnotation() {
        Assignment.make()
        Submission.make(from: .make(attempt: 1, submission_type: .student_annotation))

        let request = CanvaDocsSessionRequest(submissionId: "1", attempt: "1")
        let response = CanvaDocsSessionRequest.Response(annotation_context_launch_id: nil, canvadocs_session_url: APIURL(rawValue: URL(string: "https://instructure.com")!))
        api.mock(request, value: response)

        presenter.viewIsReady()

        XCTAssert(view.embedded is DocViewerViewController)

        guard let docViewer = view.embedded as? DocViewerViewController else { return }
        XCTAssertEqual(docViewer.filename, "")
        XCTAssertEqual(docViewer.previewURL, URL(string: "https://instructure.com")!)
        XCTAssertEqual(docViewer.fallbackURL, URL(string: "https://instructure.com")!)
    }

    func testEmbedNothing() {
        Assignment.make()
        presenter.update()

        XCTAssertNil(view.embedded)
    }

    func testEmbedWeird() {
        Assignment.make()
        Submission.make().setValue("some_invalid_string", forKey: "typeRaw")
        presenter.update()

        XCTAssertNil(view.embedded)
    }

    func testSubmit() {
        Assignment.make(from: .make(submission_types: [ .online_text_entry, .online_upload, .online_url ]))
        presenter.update()
        presenter.submit(button: UIView())

        XCTAssertNotNil(router.presented)
    }

    func testArcIDNone() {
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .pending)
        Assignment.make()
        Course.make()
        presenter.updateArc()
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .none)
    }

    func testArcIDSome() {
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .pending)
        Assignment.make()
        Course.make()
        ExternalTool.make(from: .make(id: "4", domain: "arc.instructure.com"))
        presenter.updateArc()
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .some("4"))
    }

    func testPageViewLogging() {
        Submission.make(from: .make(assignment_id: "1", attempt: 1, user_id: "1"))
        let course = Course.make()
        course.id = "1"
        let assignment = Assignment.make()
        assignment.id = "1"

        viewController.loadViewIfNeeded()
        viewController.viewWillAppear(false)
        viewController.viewWillDisappear(false)
        XCTAssertEqual(
            viewController.screenViewTrackingParameters.eventName,
            "/courses/1/assignments/1/submissions/1"
        )
    }

    func testLockedEmptyViewIsNotHidden() {
        Assignment.make(from: .make(
            allowed_extensions: ["png"],
            locked_for_user: true,
            lock_explanation: "this is locked",
            submission_types: [ .online_upload ],
            unlock_at: Date().addYears(1)
        ))
        XCTAssertFalse( presenter.lockedEmptyViewIsHidden() )
    }

    func testLockedEmptyViewIsHidden() {
        Submission.make(from: .make(assignment_id: "1", attempt: 1, user_id: "1"))
        XCTAssertTrue( presenter.lockedEmptyViewIsHidden() )
    }

    func testLockedEmptyViewIsHiddenWithUntilDateInThePast() {
        Assignment.make(from: .make(
            allowed_extensions: ["png"],
            locked_for_user: true,
            lock_at: Date().addDays(-5),
            lock_explanation: "this is locked",
            submission: .make(assignment_id: "1", id: "1", user_id: "1", workflow_state: SubmissionWorkflowState.submitted),
            submission_types: [ .online_upload ]
        ))
        XCTAssertTrue( presenter.lockedEmptyViewIsHidden() )
    }

    func testLockedEmptyViewHeaderWithQuiz() {
        Assignment.make(from: .make(
            allowed_extensions: ["png"],
            locked_for_user: true,
            lock_explanation: "this is locked",
            quiz_id: "1",
            submission_types: [ .online_upload ],
            unlock_at: Date().addYears(1)
        ))

        XCTAssertEqual( presenter.lockedEmptyViewHeader(), "Quiz Locked" )
    }

    func testLockedEmptyViewHeaderWithAssignment() {
        Assignment.make(from: .make(
            allowed_extensions: ["png"],
            locked_for_user: true,
            lock_explanation: "this is locked",
            submission_types: [ .online_upload ],
            unlock_at: Date().addYears(1)
        ))

        XCTAssertEqual( presenter.lockedEmptyViewHeader(), "Assignment Locked" )
    }
}
