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

@testable import Student
import XCTest
@testable import Core

class ArcSubmissionPresenterTests: PersistenceTestCase {
    class View: UIViewController, ArcSubmissionView {
        var url: URL?
        func load(_ url: URL) {
            self.url = url
        }

        var error: Error?
        func showError(_ error: Error) {
            self.error = error
        }
    }

    var presenter: ArcSubmissionPresenter!
    let view = View()

    override func setUp() {
        super.setUp()
        presenter = ArcSubmissionPresenter(environment: env, view: view, courseID: "1", assignmentID: "2", userID: "3", arcID: "4")
    }

    func testViewIsReady() {
        presenter.viewIsReady()
        XCTAssertEqual(view.url, env.api.baseURL.appendingPathComponent("courses/1/external_tools/4/resource_selection"))
    }

    func testSubmitForm() {
        let request = CreateSubmissionRequest(
            context: ContextModel(.course, id: "1"),
            assignmentID: "1",
            body: .init(submission: .init(
                text_comment: nil,
                submission_type: .basic_lti_launch,
                body: nil,
                url: URL(string: "https://arc.com/media/1")!,
                file_ids: nil,
                media_comment_id: nil,
                media_comment_type: nil
            ))
        )
        api.mock(request, value: nil, response: nil, error: nil)
        let form: [String: Any] = [
            "content_items": "{ \"@graph\": [ {\"url\": \"https://arc.com/media/1\"} ] }",
        ]
        let expectation = XCTestExpectation(description: "submit form")
        presenter.submit(form: form) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testSubmitFormRequestError() {
        let request = CreateSubmissionRequest(
            context: ContextModel(.course, id: "1"),
            assignmentID: "2",
            body: .init(submission: .init(
                text_comment: nil,
                submission_type: .basic_lti_launch,
                body: nil,
                url: URL(string: "https://arc.com/media/1")!,
                file_ids: nil,
                media_comment_id: nil,
                media_comment_type: nil
            ))
        )
        api.mock(request, value: nil, response: nil, error: NSError.instructureError("doh"))
        let form: [String: Any] = [
            "content_items": "{ \"@graph\": [ {\"url\": \"https://arc.com/media/1\"} ] }",
        ]
        let expectation = XCTestExpectation(description: "submit form")
        presenter.submit(form: form) { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }

    func testSubmitFormError() {
        let request = CreateSubmissionRequest(
            context: ContextModel(.course, id: "1"),
            assignmentID: "2",
            body: .init(submission: .init(
                text_comment: nil,
                submission_type: .basic_lti_launch,
                body: nil,
                url: URL(string: "https://arc.com/media/1")!,
                file_ids: nil,
                media_comment_id: nil,
                media_comment_type: nil
                ))
        )
        api.mock(request, value: nil, response: nil, error: NSError.instructureError("doh"))
        let form: [String: Any] = [
            "content_items": "{ \"@graph\": [ {\"oops\": \"https://arc.com/media/1\"} ] }",
        ]
        let expectation = XCTestExpectation(description: "submit form")
        presenter.submit(form: form) { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
