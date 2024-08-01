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
@testable import Core
@testable import Student
import TestsFoundation

class SubmissionCommentsView: SubmissionCommentsViewProtocol {
    var didReload = false
    var expectReload: XCTestExpectation?
    func reload() {
        didReload = true
        expectReload?.fulfill()
    }

    var error: Error?
    var expectError: XCTestExpectation?
    func showError(_ error: Error) {
        self.error = error
        expectError?.fulfill()
    }
}

class SubmissionCommentsPresenterTests: StudentTestCase {
    var presenter: SubmissionCommentsPresenter!
    var view: SubmissionCommentsView!

    override func setUp() {
        super.setUp()
        view = SubmissionCommentsView()
        presenter = SubmissionCommentsPresenter(env: env, view: view, context: .course("1"), assignmentID: "1", userID: "1", submissionID: "1")
    }

    func testViewIsReady() {
        presenter.viewIsReady()
        XCTAssertTrue(view.didReload)
    }

    func testUpdate() {
        presenter.update()
        XCTAssertTrue(view.didReload)
    }

    func testAddComment() {
        view.expectError = expectation(description: "error")
        view.expectError?.assertForOverFulfill = false
        presenter.addComment(text: "hello")
        wait(for: [view.expectError!], timeout: 5)
        XCTAssertNotNil(view.error)
    }

    func testAddMediaComment() {
        view.expectError = expectation(description: "error")
        view.expectError?.assertForOverFulfill = false
        presenter.addMediaComment(type: .audio, url: .stub)
        wait(for: [view.expectError!], timeout: 5)
        XCTAssertNotNil(view.error)
    }

    func testAddFileCommentError() throws {
        let file = File.make(batchID: "1", removeID: true, session: currentSession, in: UploadManager.shared.viewContext)
        view.expectError = self.expectation(description: "error")
        view.expectError?.assertForOverFulfill = false
        presenter.viewIsReady()
        presenter.addFileComment(batchID: "1")
        file.uploadError = "doh"
        try UploadManager.shared.viewContext.save()
        wait(for: [view.expectError!], timeout: 5)
    }

    func testAddFileCommentSuccess() throws {
        let file = File.make(batchID: "1", removeID: true, session: currentSession, in: UploadManager.shared.viewContext)
        api.mock(PutSubmissionGradeRequest(
            courseID: "1",
            assignmentID: "1",
            userID: "1",
            body: .init(comment: .init(fileIDs: ["1"], forGroup: true, attempt: nil), submission: nil)
        ), value: APISubmission.make(
            submission_comments: [ APISubmissionComment.make() ]
        ))
        presenter.viewIsReady()
        view.expectReload = self.expectation(description: "reload")
        view.expectReload?.assertForOverFulfill = false
        presenter.addFileComment(batchID: "1")
        file.id = "1"
        try UploadManager.shared.viewContext.save()
        wait(for: [view.expectReload!], timeout: 5)
    }

    func testAddFileCommentSuccessWithAttempFieldFlagEnabled() throws {
        let file = File.make(batchID: "1", removeID: true, session: currentSession, in: UploadManager.shared.viewContext)
        api.mock(PutSubmissionGradeRequest(
            courseID: "1",
            assignmentID: "1",
            userID: "1",
            body: .init(comment: .init(fileIDs: ["1"], forGroup: true, attempt: 19), submission: nil)
        ), value: APISubmission.make(
            submission_comments: [ APISubmissionComment.make(attempt: 19) ]
        ))
        api.mock(GetEnabledFeatureFlagsRequest(context: .course("1")), value: ["assignments_2_student"])
        presenter.viewIsReady()
        presenter.updateComments(for: 19)
        view.expectReload = self.expectation(description: "reload")
        view.expectReload?.assertForOverFulfill = false
        presenter.addFileComment(batchID: "1")
        file.id = "1"
        try UploadManager.shared.viewContext.save()
        wait(for: [view.expectReload!], timeout: 5)
        XCTAssertEqual(presenter.comments.first?.attemptFromAPI, 19)
    }

    func testCommentFilteringWithFlagEnabled() throws {
        SubmissionComment.save(.make(id: "19", attempt: 19), for: .make(), in: databaseClient)
        SubmissionComment.save(.make(id: "20", attempt: 20), for: .make(), in: databaseClient)
        try databaseClient.save()
        api.mock(GetEnabledFeatureFlagsRequest(context: .course("1")), value: ["assignments_2_student"])
        presenter.viewIsReady()
        presenter.updateComments(for: 19)
        XCTAssertEqual(presenter.comments.count, 1)
        XCTAssertEqual(presenter.comments[0].attemptFromAPI, NSNumber(value: 19))
    }

    func testCommentFilteringWithFlagDisabled() throws {
        SubmissionComment.save(.make(id: "19", attempt: 19), for: .make(), in: databaseClient)
        SubmissionComment.save(.make(id: "20", attempt: 20), for: .make(), in: databaseClient)
        try databaseClient.save()
        api.mock(GetEnabledFeatureFlagsRequest(context: .course("1")), value: [])
        presenter.viewIsReady()
        presenter.updateComments(for: 19)
        XCTAssertEqual(presenter.comments.count, 2)
    }

    func testShowAttachment() {
        let url = URL(string: "https://canvas.instructure.com/files/803/download")!
        let file = File.make(from: .make(url: url))
        presenter.showAttachment(file, from: UIViewController())
        XCTAssertTrue(router.lastRoutedTo(url, withOptions: .modal(embedInNav: true, addDoneButton: true)))
    }
}
