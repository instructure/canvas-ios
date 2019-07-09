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

class TextSubmissionPresenterTests: PersistenceTestCase {
    var dismissed = false
    var presenter: TextSubmissionPresenter!
    var resultingError: Error?
    var navigationController: UINavigationController?

    override func setUp() {
        super.setUp()
        presenter = TextSubmissionPresenter(env: env, view: self, courseID: "1", assignmentID: "1", userID: "1")
    }

    func testSubmitError() {
        let text = "<b>submission</b>"
        let error = NSError(domain: "test", code: 5, userInfo: nil)
        MockURLSession.mock(submissionRequest(for: text), value: nil, error: error)
        let expectation = self.expectation(description: "got an error")
        presenter.submit(text) { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testSubmitSuccess() {
        let text = "<b>submission</b>"
        MockURLSession.mock(submissionRequest(for: text), value: APISubmission.make())
        let expectation = self.expectation(description: "dismissed")
        presenter.submit(text) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func submissionRequest(for body: String?) -> CreateSubmissionRequest {
        return CreateSubmissionRequest(
            context: ContextModel(.course, id: "1"),
            assignmentID: "1",
            body: .init(submission: .init(
                text_comment: nil,
                submission_type: .online_text_entry,
                body: body,
                url: nil,
                file_ids: nil,
                media_comment_id: nil,
                media_comment_type: nil
            ))
        )
    }
}

extension TextSubmissionPresenterTests: TextSubmissionViewProtocol {}
