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

class UrlSubmissionPresenterTests: XCTestCase {
    var dismissed = false
    var presenter: UrlSubmissionPresenter!
    var resultingUrl: URL?
    var resultingError: Error?
    var navigationController: UINavigationController?

    override func setUp() {
        presenter = UrlSubmissionPresenter(view: self, courseID: "1", assignmentID: "1", userID: "1", env: testEnvironment())
    }

    func testScrubUrl() {
        presenter.scrubAndLoadUrl(text: "www.google.com")
        XCTAssertEqual(resultingUrl?.absoluteString, "http://www.google.com")
    }

    func testScrubUrlWithInvalidUrl() {
        presenter.scrubAndLoadUrl(text: "")
        XCTAssertNil(resultingUrl)
    }

    func testInvalidUrl() {
        presenter.submit("")
        XCTAssertNotNil(resultingError)
    }

    func testSubmitError() {
        let url = URL(string: "https://instructure.com")
        let api = presenter.env.api as? MockAPI
        let error = NSError(domain: "test", code: 5, userInfo: nil)
        api?.mock(submissionRequest(for: url), value: nil, response: nil, error: error)
        presenter.submit(url?.absoluteString)
        let expectation = BlockExpectation(description: "got an error") { self.resultingError != nil }
        wait(for: [expectation], timeout: 10)
    }

    func testSubmitSuccess() {
        let url = URL(string: "https://instructure.com")
        let api = presenter.env.api as? MockAPI
        api?.mock(submissionRequest(for: url), value: APISubmission.make(), response: nil, error: nil)
        presenter.submit(url?.absoluteString)
        let expectation = BlockExpectation(description: "dismissed") { self.dismissed }
        wait(for: [expectation], timeout: 10)
    }

    func submissionRequest(for url: URL?) -> CreateSubmissionRequest {
        return CreateSubmissionRequest(
            context: ContextModel(.course, id: "1"),
            assignmentID: "1",
            body: .init(submission: .init(
                text_comment: nil,
                submission_type: .online_url,
                body: nil,
                url: url,
                file_ids: nil,
                media_comment_id: nil,
                media_comment_type: nil
            ))
        )
    }
}

extension UrlSubmissionPresenterTests: UrlSubmissionViewProtocol {
    func dismiss() {
        dismissed = true
    }

    func loadUrl(url: URL) {
        resultingUrl = url
    }

    func showError(_ error: Error) {
        resultingError = error
    }
}
