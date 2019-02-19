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

class SubmissionDetailsPresenterTests: PersistenceTestCase {
    var color: UIColor?
    var titleSubtitleView = TitleSubtitleView.create()
    var navigationController: UINavigationController?
    var navigationItem = UINavigationItem()

    var resultingAssignment: SubmissionDetailsViewAssignmentModel?
    var resultingSubmissions: [SubmissionDetailsViewModel]?
    var resultingAttempt: Int = 0
    var resultingError: Error?
    var resultingEmbed: UIViewController?
    var presenter: SubmissionDetailsPresenter!

    override func setUp() {
        super.setUp()
        let mockUseCase =  MockUseCase {}
        presenter = SubmissionDetailsPresenter(env: env, view: self, context: ContextModel(.course, id: "1"), assignmentID: "1", userID: "1", useCaseFactory: { _ in return mockUseCase })
    }

    func testDefaultUseCase() {
        presenter = SubmissionDetailsPresenter(env: env, view: self, context: ContextModel(.course, id: "1"), assignmentID: "1", userID: "3")
        XCTAssert(presenter.useCaseFactory(false) is SubmissionDetailsUseCase)
    }

    func testLoadNoAssignment() {
        presenter.loadData()
        XCTAssertEqual(titleSubtitleView.subtitle, "")
        XCTAssertNil(resultingAssignment)
        XCTAssertNil(resultingSubmissions)
        XCTAssertEqual(resultingAttempt, 0)
    }

    func testLoadNoCourse() {
        let a = Assignment.make()
        presenter.loadData()
        XCTAssertEqual(titleSubtitleView.subtitle, "")
        XCTAssertEqual(resultingAssignment?.dueAt, a.dueAt)
        XCTAssertEqual(resultingSubmissions?.count, 0)
        XCTAssertEqual(resultingAttempt, 0)
    }

    func testLoadNoSubmissions() {
        let a = Assignment.make()
        Course.make()

        presenter.loadData()

        XCTAssertEqual(titleSubtitleView.subtitle, a.name)
        XCTAssertEqual(resultingAssignment?.dueAt, a.dueAt)
        XCTAssertEqual(resultingSubmissions?.count, 0)
        XCTAssertEqual(resultingAttempt, 0)
    }

    func testLoad() {
        let a = Assignment.make()
        Course.make()
        let s = Submission.make()

        presenter.loadData()

        XCTAssertEqual(titleSubtitleView.subtitle, a.name)
        XCTAssertEqual(resultingAssignment?.dueAt, a.dueAt)
        XCTAssertEqual(resultingSubmissions?[0].workflowState, s.workflowState)
        XCTAssertEqual(resultingAttempt, 1)
    }

    func testSelect() {
        Assignment.make()
        Course.make()
        Submission.make()

        presenter.select(attempt: 5)
        XCTAssertEqual(resultingAttempt, 5)
    }

    func testLoadDataFromServer() {
        let expectation = XCTestExpectation(description: "Expect use case to work")
        var assignment: Assignment!
        var submission: Submission!
        let useCase = MockUseCase {
            submission = Submission.make()
            assignment = Assignment.make()
            Course.make()
            expectation.fulfill()
        }
        presenter = SubmissionDetailsPresenter(env: env, view: self, context: ContextModel(.course, id: "1"), assignmentID: "1", userID: "1", useCaseFactory: { _ in return useCase })

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 0.1)

        presenter.controllerDidChangeContent(presenter.submissionFrc)

        XCTAssertEqual(titleSubtitleView.subtitle, assignment.name)
        XCTAssertEqual(resultingAssignment?.dueAt, assignment.dueAt)
        XCTAssertEqual(resultingSubmissions?[0].workflowState, submission.workflowState)
        XCTAssertEqual(resultingAttempt, 1)
    }

    func testEmbedExternalTool() {
        let assignment = Assignment.make([ "submissionTypesRaw": [ "external_tool" ] ])
        let submission = Submission.make([ "typeRaw": "external_tool" ])

        presenter.embed(submission, assignment: assignment)
        XCTAssert(resultingEmbed is ExternalToolSubmissionContentViewController)
    }

    func testEmbedQuiz() {
        let assignment = Assignment.make([ "quizID": "1" ])
        let submission = Submission.make([ "typeRaw": "online_quiz", "attempt": 2 ])

        presenter.embed(submission, assignment: assignment)
        XCTAssert(resultingEmbed is CoreWebViewController)
        XCTAssertEqual(resultingEmbed?.view.accessibilityIdentifier, "SubmissionDetailsPage.onlineQuizWebView")
    }

    func testEmbedTextEntry() {
        let assignment = Assignment.make()
        let submission = Submission.make([ "typeRaw": "online_text_entry" ])

        presenter.embed(submission, assignment: assignment)
        XCTAssert(resultingEmbed is CoreWebViewController)
        XCTAssertEqual(resultingEmbed?.view.accessibilityIdentifier, "SubmissionDetailsPage.onlineTextEntryWebView")
    }

    func testEmbedUpload() {
        let assignment = Assignment.make()
        let submission = Submission.make([
            "typeRaw": "online_upload",
            "attachments": Set([ File.make() ]),
        ])

        presenter.embed(submission, assignment: assignment)
        XCTAssert(resultingEmbed is DocViewerViewController)
    }

    func testEmbedDiscussion() {
        let assignment = Assignment.make()
        let submission = Submission.make([ "typeRaw": "discussion_topic", "previewUrl": URL(string: "preview") ])

        presenter.embed(submission, assignment: assignment)
        XCTAssert(resultingEmbed is CoreWebViewController)
        XCTAssertEqual(resultingEmbed?.view.accessibilityIdentifier, "SubmissionDetailsPage.discussionWebView")
    }

    func testEmbedURL() {
        let assignment = Assignment.make()
        let submission = Submission.make([ "typeRaw": "online_url" ])

        presenter.embed(submission, assignment: assignment)
        XCTAssert(resultingEmbed is UrlSubmissionContentViewController)
    }
}

extension SubmissionDetailsPresenterTests: SubmissionDetailsViewProtocol {
    func update(assignment: SubmissionDetailsViewAssignmentModel, submissions: [SubmissionDetailsViewModel], selectedAttempt: Int) {
        resultingAssignment = assignment
        resultingSubmissions = submissions
        resultingAttempt = selectedAttempt
    }

    func embed(_ controller: UIViewController?) {
        resultingEmbed = controller
    }

    func showError(_ error: Error) {
        resultingError = error
    }
}
