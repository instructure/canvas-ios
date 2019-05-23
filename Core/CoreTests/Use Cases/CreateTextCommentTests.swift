//
// Copyright (C) 2019-present Instructure, Inc.
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

class CreateTextCommentTests: CoreTestCase {
    let create = CreateTextComment(courseID: "1", assignmentID: "2", userID: "3", submissionID: "4", isGroup: false, text: "comment")
    var comment: SubmissionComment?
    var error: Error?

    override func setUp() {
        super.setUp()
        create.env = environment
        create.callback = { [weak self] (comment, error) in
            self?.comment = comment
            self?.error = error
        }
    }

    func testCancel() {
        XCTAssertNoThrow(create.cancel())
    }

    func testFetch() {
        create.fetch(environment: environment, create.callback)
        XCTAssert(create.env === environment)
    }

    func testSavePlaceholderError() {
        create.env = AppEnvironment()
        create.savePlaceholder()
        XCTAssertNotNil(error)
    }

    func testPutCommentError() {
        api.mock(PutSubmissionGradeRequest(
            courseID: create.courseID,
            assignmentID: create.assignmentID,
            userID: create.userID,
            body: .init(comment: .init(text: "comment", forGroup: create.isGroup), submission: nil)
        ), error: NSError.internalError())
        create.putComment()
        XCTAssertNotNil(error)
    }

    func testPlaceholderCreated() {
        let called = expectation(description: "called")
        create.fetch(environment: environment) { [weak self] comment, error in
            self?.comment = comment
            self?.error = error
            called.fulfill()
        }
        wait(for: [called], timeout: 5)
        XCTAssertNil(comment)
        XCTAssertNil(error)

        let comments: [SubmissionComment] = databaseClient.fetch()
        XCTAssertEqual(comments.first?.id.hasPrefix("placeholder-"), true)
        XCTAssertEqual(comments.first?.comment, create.text)
    }

    func testSuccess() {
        api.mock(PutSubmissionGradeRequest(
            courseID: create.courseID,
            assignmentID: create.assignmentID,
            userID: create.userID,
            body: .init(comment: .init(text: "comment", forGroup: create.isGroup), submission: nil)
        ), value: APISubmission.make(
            submission_comments: [ .make() ]
        ))
        let called = expectation(description: "called")
        create.fetch(environment: environment) { [weak self] comment, error in
            self?.comment = comment
            self?.error = error
            called.fulfill()
        }
        wait(for: [called], timeout: 5)
        XCTAssertNotNil(comment)
        XCTAssertNil(error)
    }
}
