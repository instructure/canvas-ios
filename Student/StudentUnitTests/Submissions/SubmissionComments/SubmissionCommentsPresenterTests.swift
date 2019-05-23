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

class SubmissionCommentsPresenterTests: PersistenceTestCase {
    var presenter: SubmissionCommentsPresenter!
    var view: SubmissionCommentsView!

    override func setUp() {
        super.setUp()
        view = SubmissionCommentsView()
        presenter = SubmissionCommentsPresenter(env: env, view: view, context: ContextModel(.course, id: "1"), assignmentID: "1", userID: "1", submissionID: "1")
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
        presenter.addMediaComment(type: .audio, url: URL(string: "/")!)
        wait(for: [view.expectError!], timeout: 5)
        XCTAssertNotNil(view.error)
    }

    func testAddFileCommentError() throws {
        let file = File.make(["id": nil, "batchID": "1"])
        view.expectError = self.expectation(description: "error")
        view.expectError?.assertForOverFulfill = false
        presenter.viewIsReady()
        presenter.addFileComment(batchID: "1")
        file.uploadError = "doh"
        try databaseClient.save()
        wait(for: [view.expectError!], timeout: 5)
    }

    func testAddFileCommentSuccess() throws {
        let file = File.make(["id": nil, "batchID": "1"])
        api.mock(PutSubmissionGradeRequest(
            courseID: "1",
            assignmentID: "1",
            userID: "1",
            body: .init(comment: .init(fileIDs: ["1"], forGroup: true), submission: nil)
        ), value: APISubmission.make([
            "submission_comments": [ APISubmissionComment.fixture() ],
        ]))
        presenter.viewIsReady()
        view.expectReload = self.expectation(description: "reload")
        view.expectReload?.assertForOverFulfill = false
        presenter.addFileComment(batchID: "1")
        file.id = "1"
        try databaseClient.save()
        wait(for: [view.expectReload!], timeout: 5)
    }

    func testShowAttachment() {
        let url = URL(string: "https://canvas.instructure.com/files/803/download")!
        let file = File.make(["url": url])
        presenter.showAttachment(file, from: UIViewController())
        XCTAssertTrue(router.lastRoutedTo(url, withOptions: [.modal, .embedInNav]))
    }
}
