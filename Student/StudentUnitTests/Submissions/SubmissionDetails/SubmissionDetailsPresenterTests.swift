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
        Submission.make(["assignmentID": "1", "userID": "1", "attempt": 1])
        Submission.make(["assignmentID": "1", "userID": "1", "attempt": 2, "attachments": Set([File.make([ "id": "1" ]), File.make([ "id": "2" ])])])
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
        Submission.make(["assignmentID": "1", "userID": "1", "attempt": 1, "attachments": Set([File.make([ "id": "1" ])])])
        Submission.make(["assignmentID": "1", "userID": "1", "attempt": 2])
        presenter.select(attempt: 1)
        XCTAssertEqual(presenter.selectedAttempt, 1)
        XCTAssertEqual(presenter.selectedFileID, "1")
    }

    func testSelectFileID() {
        Submission.make(["assignmentID": "1", "userID": "1", "attempt": 1])
        Submission.make(["assignmentID": "1", "userID": "1", "attempt": 2, "attachments": Set([File.make([ "id": "1" ]), File.make([ "id": "2" ])])])
        presenter.select(fileID: "2")
        XCTAssertEqual(presenter.selectedFileID, "2")
        presenter.select(fileID: "bogus")
        XCTAssertEqual(presenter.selectedFileID, "1")
    }

    func testSelectDrawerTabComments() {
        Submission.make(["assignmentID": "1", "userID": "1", "attempt": 1, "attachments": Set([File.make([ "id": "1" ]), File.make([ "id": "2" ])])])
        Submission.make(["assignmentID": "1", "userID": "1", "attempt": 2, "attachments": Set([File.make([ "id": "3" ]), File.make([ "id": "4" ])])])
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
        Submission.make(["assignmentID": "1", "userID": "1", "attempt": 1, "attachments": Set([File.make([ "id": "1" ]), File.make([ "id": "2" ])])])
        Submission.make(["assignmentID": "1", "userID": "1", "attempt": 2, "attachments": Set([File.make([ "id": "3" ]), File.make([ "id": "4" ])])])
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
        Submission.make(["assignmentID": "1", "userID": "1", "attempt": 2, "attachments": Set([File.make([ "id": "1" ]), File.make([ "id": "2" ])])])
        presenter.select(drawerTab: .rubric)
        XCTAssertEqual(presenter.selectedDrawerTab, .rubric)
        XCTAssertNil(view.embeddedInDrawer)
    }

    func testEmbedExternalTool() {
        Assignment.make([ "submissionTypesRaw": [ "external_tool" ] ])
        Submission.make([ "typeRaw": "external_tool" ])
        presenter.update()

        XCTAssert(view.embedded is ExternalToolSubmissionContentViewController)
    }

    func testEmbedQuiz() {
        Assignment.make([ "quizID": "1" ])
        Submission.make([ "typeRaw": "online_quiz", "attempt": 2 ])
        presenter.update()

        XCTAssert(view.embedded is CoreWebViewController)
        XCTAssertEqual(view.embedded?.view.accessibilityIdentifier, "SubmissionDetails.onlineQuizWebView")
    }

    func testEmbedTextEntry() {
        Assignment.make()
        Submission.make([ "typeRaw": "online_text_entry" ])
        presenter.update()

        XCTAssert(view.embedded is CoreWebViewController)
        XCTAssertEqual(view.embedded?.view.accessibilityIdentifier, "SubmissionDetails.onlineTextEntryWebView")
    }

    func testEmbedUpload() {
        Assignment.make()
        Submission.make([
            "typeRaw": "online_upload",
            "attachments": Set([ File.make() ]),
        ])
        presenter.update()

        XCTAssert(view.embedded is DocViewerViewController)
    }

    func testEmbedDiscussion() {
        Assignment.make()
        Submission.make([ "typeRaw": "discussion_topic", "previewUrl": URL(string: "preview") ])
        presenter.update()

        XCTAssert(view.embedded is CoreWebViewController)
        XCTAssertEqual(view.embedded?.view.accessibilityIdentifier, "SubmissionDetails.discussionWebView")
    }

    func testEmbedURL() {
        Assignment.make()
        Submission.make([ "typeRaw": "online_url" ])
        presenter.update()

        XCTAssert(view.embedded is UrlSubmissionContentViewController)
    }

    func testEmbedMediaSubmission() {
        Assignment.make()
        Submission.make([ "typeRaw": "media_recording", "mediaComment": MediaComment.make() ])
        presenter.update()

        XCTAssert(view.embedded is AVPlayerViewController)
    }

    func testEmbedNothing() {
        Assignment.make()
        presenter.update()

        XCTAssertNil(view.embedded)
    }

    func testEmbedWeird() {
        Assignment.make()
        Submission.make([ "typeRaw": "some_invalid_string" ])
        presenter.update()

        XCTAssertNil(view.embedded)
    }

    func testSubmit() {
        Assignment.make([ "submissionTypesRaw": [ "online_text_entry", "online_upload", "online_url" ] ])
        presenter.update()
        presenter.submit(button: UIView())

        XCTAssertNotNil(view.presented)
    }
}
