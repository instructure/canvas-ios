//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

class CreateTextCommentTests: CoreTestCase {
    lazy var create = CreateTextComment(
        env: environment,
        courseID: "1",
        assignmentID: "2",
        userID: "3",
        isGroup: false,
        text: "comment",
        attempt: nil
    )
    var comment: SubmissionComment?
    var error: Error?

    override func setUp() {
        super.setUp()
        create.callback = { [weak self] (comment, error) in
            self?.comment = comment
            self?.error = error
        }
    }

    func testCancel() {
        XCTAssertNoThrow(create.cancel())
    }

    func testFetch() {
        create.fetch(create.callback)
        XCTAssert(create.env === environment)
    }

    func testSavePlaceholderError() {
        environment.currentSession = nil
        create.savePlaceholder()
        XCTAssertNotNil(error)
    }

    func testPutCommentError() {
        api.mock(PutSubmissionGradeRequest(
            courseID: create.courseID,
            assignmentID: create.assignmentID,
            userID: create.userID,
            body: .init(comment: .init(text: "comment", forGroup: create.isGroup, attempt: nil), submission: nil)
        ), error: NSError.internalError())
        create.putComment()
        XCTAssertNotNil(error)
    }

    func testPlaceholderCreated() {
        let called = expectation(description: "called")
        create.fetch { [weak self] comment, error in
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
            body: .init(comment: .init(text: "comment", forGroup: create.isGroup, attempt: nil), submission: nil)
        ), value: APISubmission.make(
            submission_comments: [ .make() ]
        ))
        let called = expectation(description: "called")
        create.fetch { [weak self] comment, error in
            self?.comment = comment
            self?.error = error
            called.fulfill()
        }
        wait(for: [called], timeout: 5)
        XCTAssertNotNil(comment)
        XCTAssertNil(error)
    }

    func testSuccessWithAttemptField() {
        lazy var create = CreateTextComment(
            env: environment,
            courseID: "1",
            assignmentID: "2",
            userID: "3",
            isGroup: false,
            text: "comment",
            attempt: 19
        )
        api.mock(PutSubmissionGradeRequest(
            courseID: create.courseID,
            assignmentID: create.assignmentID,
            userID: create.userID,
            body: .init(comment: .init(text: "comment", forGroup: create.isGroup, attempt: 19), submission: nil)
        ), value: APISubmission.make(
            submission_comments: [ .make(attempt: 19) ]
        ))
        let called = expectation(description: "called")
        create.fetch { [weak self] comment, error in
            self?.comment = comment
            self?.error = error
            called.fulfill()
        }
        wait(for: [called], timeout: 5)
        XCTAssertNotNil(comment)
        XCTAssertEqual(comment?.attemptFromAPI, 19)
        XCTAssertNil(error)
    }
}
