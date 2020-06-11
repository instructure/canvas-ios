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
