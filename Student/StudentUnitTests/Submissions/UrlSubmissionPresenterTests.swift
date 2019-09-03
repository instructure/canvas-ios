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
        let error = NSError(domain: "test", code: 5, userInfo: nil)
        MockURLSession.mock(submissionRequest(for: url), value: nil, response: nil, error: error)
        presenter.submit(url?.absoluteString)
        let expectation = BlockExpectation(description: "got an error") { self.resultingError != nil }
        wait(for: [expectation], timeout: 10)
    }

    func testSubmitSuccess() {
        let url = URL(string: "https://instructure.com")
        MockURLSession?.mock(submissionRequest(for: url), value: APISubmission.make(), response: nil, error: nil)
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
