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
        presenter = TextSubmissionPresenter(env: env, view: self, courseID: "1", assignmentID: "1", userID: "1")
    }

    func testSubmitError() {
        let text = "<b>submission</b>"
        let error = NSError(domain: "test", code: 5, userInfo: nil)
        (presenter.env.api as! MockAPI).mock(submissionRequest(for: text), error: error)
        presenter.submit(text)
        let expectation = BlockExpectation(description: "got an error") { self.resultingError != nil }
        wait(for: [expectation], timeout: 10)
    }

    func testSubmitSuccess() {
        let text = "<b>submission</b>"
        (presenter.env.api as! MockAPI).mock(submissionRequest(for: text), value: APISubmission.make())
        presenter.submit(text)
        let expectation = BlockExpectation(description: "dismissed") { self.dismissed }
        wait(for: [expectation], timeout: 10)
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

extension TextSubmissionPresenterTests: TextSubmissionViewProtocol {
    func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        dismissed = true
    }

    func showError(_ error: Error) {
        resultingError = error
    }
}
