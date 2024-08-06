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

class UrlSubmissionPresenterTests: StudentTestCase {
    var dismissed = false
    var presenter: UrlSubmissionPresenter!
    var resultingUrl: URL?
    var resultingError: Error?
    var navigationController: UINavigationController?
    var onError: (() -> Void)?
    var onDismiss: (() -> Void)?

    override func setUp() {
        super.setUp()
        presenter = UrlSubmissionPresenter(view: self, courseID: "1", assignmentID: "1", userID: "1", env: env)
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
        api.mock(submissionRequest(for: url), error: error)
        let expectation = XCTestExpectation(description: "got an error")
        onError = expectation.fulfill
        presenter.submit(url?.absoluteString)
        wait(for: [expectation], timeout: 10)
        XCTAssertNotNil(resultingError)
    }

    func testSubmitSuccess() {
        let url = URL(string: "https://instructure.com")
        api.mock(submissionRequest(for: url), value: .make())
        let expectation = XCTestExpectation(description: "dismissed")
        onDismiss = expectation.fulfill
        presenter.submit(url?.absoluteString)
        wait(for: [expectation], timeout: 10)
        XCTAssertNil(resultingError)
    }

    func submissionRequest(for url: URL?) -> CreateSubmissionRequest {
        return CreateSubmissionRequest(
            context: .course("1"),
            assignmentID: "1",
            body: .init(submission: .init(
                text_comment: nil,
                group_comment: nil,
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
        onDismiss?()
    }

    func loadUrl(url: URL) {
        resultingUrl = url
    }

    func showAlert(title: String?, message: String?) {}

    func showError(_ error: Error) {
        resultingError = error
        onError?()
    }
}
