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
