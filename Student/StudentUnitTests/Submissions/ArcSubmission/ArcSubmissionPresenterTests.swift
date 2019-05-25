//
// Copyright (C) 2019-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
        wait(for: [expectation], timeout: 0.1)
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
        wait(for: [expectation], timeout: 0.1)
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
        wait(for: [expectation], timeout: 0.1)
    }
}
