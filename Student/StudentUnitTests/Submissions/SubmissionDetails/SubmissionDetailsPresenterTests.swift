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

class SubmissionDetailsView: SubmissionDetailsViewProtocol {
    var didReload = false
    var reloaded = XCTestExpectation(description: "Reloaded")
    var didEmbed = false
    var embedded = XCTestExpectation(description: "Embedded")

    func reload() {
        didReload = true
        reloaded.fulfill()
    }

    func embed() {
        didEmbed = true
        embedded.fulfill()
    }

    let navigationItem = UINavigationItem(title: "Test")
}

class SubmissionDetailsPresenterTests: PersistenceTestCase {
    var presenter: SubmissionDetailsPresenter!
    var view: SubmissionDetailsView!

    override func setUp() {
        super.setUp()
        view = SubmissionDetailsView()
        presenter = SubmissionDetailsPresenter(env: env, view: view, context: ContextModel(.course, id: "1"), assignmentID: "1", userID: "1")
    }

    func testLoadData() {
        Submission.make(["assignmentID": "1", "userID": "1"])
        Assignment.make(["id": "1"])

        presenter.viewIsReady()
        wait(for: [view.reloaded, view.embedded], timeout: 0.1)
        XCTAssertTrue(view.didReload)
        XCTAssertTrue(view.didEmbed)

        XCTAssertEqual(presenter.assignment.count, 1)
        XCTAssertEqual(presenter.submissions.count, 1)
    }

    func testSubmissionForAttempt() {
        let s = Submission.make(["assignmentID": "1", "userID": "1", "attempt": 1])

        presenter.viewIsReady()
        wait(for: [view.reloaded], timeout: 0.1)

        XCTAssertEqual(presenter.submissionFor(attempt: 1), s)
    }

    func testEmbedExternalTool() {
        Assignment.make([ "submissionTypesRaw": [ "external_tool" ] ])
        Submission.make([ "typeRaw": "external_tool" ])

        presenter.viewIsReady()
        wait(for: [view.reloaded], timeout: 0.1)

        let vc = presenter.viewControllerFor(attempt: 1)
        XCTAssert(vc is ExternalToolSubmissionContentViewController)
    }

    func testEmbedQuiz() {
        Assignment.make([ "quizID": "1" ])
        Submission.make([ "typeRaw": "online_quiz", "attempt": 2 ])

        presenter.viewIsReady()
        wait(for: [view.reloaded], timeout: 0.1)

        let vc = presenter.viewControllerFor(attempt: 2)
        XCTAssert(vc is CoreWebViewController)
        XCTAssertEqual(vc?.view.accessibilityIdentifier, "SubmissionDetailsPage.onlineQuizWebView")
    }

    func testEmbedTextEntry() {
        Assignment.make()
        Submission.make([ "typeRaw": "online_text_entry" ])

        presenter.viewIsReady()
        wait(for: [view.reloaded], timeout: 0.1)

        let vc = presenter.viewControllerFor(attempt: 1)
        XCTAssert(vc is CoreWebViewController)
        XCTAssertEqual(vc?.view.accessibilityIdentifier, "SubmissionDetailsPage.onlineTextEntryWebView")
    }

    func testEmbedUpload() {
        Assignment.make()
        Submission.make([
            "typeRaw": "online_upload",
            "attachments": Set([ File.make() ]),
        ])

        presenter.viewIsReady()
        wait(for: [view.reloaded], timeout: 0.1)

        let vc = presenter.viewControllerFor(attempt: 1)
        XCTAssert(vc is DocViewerViewController)
    }

    func testEmbedDiscussion() {
        Assignment.make()
        Submission.make([ "typeRaw": "discussion_topic", "previewUrl": URL(string: "preview") ])

        presenter.viewIsReady()
        wait(for: [view.reloaded], timeout: 0.1)

        let vc = presenter.viewControllerFor(attempt: 1)
        XCTAssert(vc is CoreWebViewController)
        XCTAssertEqual(vc?.view.accessibilityIdentifier, "SubmissionDetailsPage.discussionWebView")
    }

    func testEmbedURL() {
        Assignment.make()
        Submission.make([ "typeRaw": "online_url" ])

        presenter.viewIsReady()
        wait(for: [view.reloaded], timeout: 0.1)

        let vc = presenter.viewControllerFor(attempt: 1)
        XCTAssert(vc is UrlSubmissionContentViewController)
    }
}
