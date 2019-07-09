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
import Core
import TestsFoundation
import AVKit

class SubmissionDetailsView: SubmissionDetailsViewProtocol {
    func open(_ url: URL) {}

    var color: UIColor?
    var navigationController: UINavigationController?
    let navigationItem = UINavigationItem(title: "Test")
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
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        presented = viewControllerToPresent
    }
}

class SubmissionDetailsPresenterTests: PersistenceTestCase {
    var presenter: SubmissionDetailsPresenter!
    var view: SubmissionDetailsView!

    override func setUp() {
        super.setUp()
        view = SubmissionDetailsView()
        presenter = SubmissionDetailsPresenter(env: env, view: view, context: ContextModel(.course, id: "1"), assignmentID: "1", userID: "1")
    }

    func testViewIsReady() {
        presenter.viewIsReady()
        XCTAssertTrue(view.didReloadNavbar)
    }

    func testUpdate() {
        Submission.make(from: .make(assignment_id: "1", user_id: "1", attempt: 1))
        Submission.make(from: .make(assignment_id: "1", user_id: "1", attempt: 2, attachments: [ .make(id: "1"), .make(id: "2") ]))
        presenter.selectedAttempt = 7
        presenter.selectedFileID = "7"
        presenter.update()
        XCTAssertEqual(presenter.selectedAttempt, 2)
        XCTAssertEqual(presenter.selectedFileID, "1")
        XCTAssertTrue(view.didEmbed)
        XCTAssertTrue(view.didEmbedInDrawer)
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
        Submission.make(from: .make(assignment_id: "1", user_id: "1", attempt: 1, attachments: [ .make(id: "1") ]))
        Submission.make(from: .make(assignment_id: "1", user_id: "1", attempt: 2))
        presenter.select(attempt: 1)
        XCTAssertEqual(presenter.selectedAttempt, 1)
        XCTAssertEqual(presenter.selectedFileID, "1")
    }

    func testSelectFileID() {
        Submission.make(from: .make(assignment_id: "1", user_id: "1", attempt: 1))
        Submission.make(from: .make(assignment_id: "1", user_id: "1", attempt: 2, attachments: [ .make(id: "1"), .make(id: "2") ]))
        presenter.select(fileID: "2")
        XCTAssertEqual(presenter.selectedFileID, "2")
        presenter.select(fileID: "bogus")
        XCTAssertEqual(presenter.selectedFileID, "1")
    }

    func testSelectDrawerTabComments() {
        Submission.make(from: .make(assignment_id: "1", user_id: "1", attempt: 1, attachments: [ .make(id: "1"), .make(id: "2") ]))
        Submission.make(from: .make(assignment_id: "1", user_id: "1", attempt: 2, attachments: [ .make(id: "3"), .make(id: "4") ]))
        presenter.update()
        presenter.select(drawerTab: nil)
        XCTAssertEqual(presenter.selectedDrawerTab, .comments)
        XCTAssert(view.embeddedInDrawer is SubmissionCommentsViewController)

        // does not reembed when attempt changes
        view.embeddedInDrawer = nil
        presenter.select(attempt: 1)
        XCTAssertNil(view.embeddedInDrawer)
    }

    func testSelectDrawerTabFiles() {
        Submission.make(from: .make(assignment_id: "1", user_id: "1", attempt: 1, attachments: [ .make(id: "1"), .make(id: "2") ]))
        Submission.make(from: .make(assignment_id: "1", user_id: "1", attempt: 2, attachments: [ .make(id: "3"), .make(id: "4") ]))
        presenter.update()
        presenter.select(drawerTab: .files)
        XCTAssertEqual(presenter.selectedDrawerTab, .files)
        XCTAssert(view.embeddedInDrawer is SubmissionFilesViewController)

        // reembeds when attempt changes
        view.embeddedInDrawer = nil
        presenter.select(attempt: 1)
        XCTAssert(view.embeddedInDrawer is SubmissionFilesViewController)
    }

    func testSelectDrawerTabRubric() {
        Submission.make(from: .make(assignment_id: "1", user_id: "1", attempt: 1, attachments: [ .make(id: "1"), .make(id: "2") ]))
        presenter.select(drawerTab: .rubric)
        XCTAssertEqual(presenter.selectedDrawerTab, .rubric)
        XCTAssertNil(view.embeddedInDrawer)
    }

    func testEmbedExternalTool() {
        Assignment.make(from: .make(submission_types: [ .external_tool ]))
        Submission.make(from: .make(submission_type: .external_tool))
        presenter.update()

        XCTAssert(view.embedded is ExternalToolSubmissionContentViewController)
    }

    func testEmbedQuiz() {
        Assignment.make(from: .make(quiz_id: "1"))
        Submission.make(from: .make(submission_type: .online_quiz, attempt: 2))
        presenter.update()

        XCTAssert(view.embedded is CoreWebViewController)
        XCTAssertEqual(view.embedded?.view.accessibilityIdentifier, "SubmissionDetails.onlineQuizWebView")
    }

    func testEmbedTextEntry() {
        Assignment.make()
        Submission.make(from: .make(submission_type: .online_text_entry))
        presenter.update()

        XCTAssert(view.embedded is CoreWebViewController)
        XCTAssertEqual(view.embedded?.view.accessibilityIdentifier, "SubmissionDetails.onlineTextEntryWebView")
    }

    func testEmbedUpload() {
        Assignment.make()
        Submission.make(from: .make(
            submission_type: .online_upload,
            attachments: [ .make() ]
        ))
        presenter.update()

        XCTAssert(view.embedded is DocViewerViewController)
    }

    func testEmbedDiscussion() {
        Assignment.make()
        Submission.make(from: .make(submission_type: .discussion_topic, preview_url: URL(string: "preview")))
        presenter.update()

        XCTAssert(view.embedded is CoreWebViewController)
        XCTAssertEqual(view.embedded?.view.accessibilityIdentifier, "SubmissionDetails.discussionWebView")
    }

    func testEmbedURL() {
        Assignment.make()
        Submission.make(from: .make(submission_type: .online_url))
        presenter.update()

        XCTAssert(view.embedded is UrlSubmissionContentViewController)
    }

    func testEmbedMediaSubmission() {
        Assignment.make()
        Submission.make(from: .make(submission_type: .media_recording, media_comment: .make() ))
        presenter.update()

        XCTAssert(view.embedded is AVPlayerViewController)
    }

    func testEmbedArc() {
        Assignment.make()
        Submission.make(from: .make(submission_type: .basic_lti_launch))
        presenter.update()

        XCTAssert(view.embedded is ExternalToolSubmissionContentViewController)
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

        XCTAssertNotNil(view.presented)
    }

    func testArcIDNone() {
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .pending)
        Assignment.make()
        Course.make()
        presenter.viewIsReady()
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .none)
    }

    func testArcIDSome() {
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .pending)
        Assignment.make()
        Course.make()
        ExternalTool.make(from: .make(id: "4", domain: "arc.instructure.com"), forCourse: "1")
        presenter.viewIsReady()
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .some("4"))
    }
}
