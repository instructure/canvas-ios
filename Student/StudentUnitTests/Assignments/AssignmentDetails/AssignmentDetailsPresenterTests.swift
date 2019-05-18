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
@testable import Student
@testable import Core
import SafariServices
import TestsFoundation

class AssignmentDetailsPresenterTests: PersistenceTestCase {
    var resultingError: NSError?
    var resultingAssignment: Assignment?
    var resultingQuiz: Quiz?
    var resultingBaseURL: URL?
    var resultingSubtitle: String?
    var resultingBackgroundColor: UIColor?
    var presenter: AssignmentDetailsPresenter!
    var expectation = XCTestExpectation(description: "expectation")
    var resultingButtonTitle: String?
    var navigationController: UINavigationController?

    class MockButton: SubmissionButtonPresenter {
        var submitted = false
        override func submitAssignment(_ assignment: Assignment, button: UIView) {
            submitted = true
        }
    }
    lazy var mockButton = MockButton(view: self, assignmentID: "1")

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: "target")
        presenter.submissionButtonPresenter = mockButton
    }

    func testLoadCourse() {
        //  given
        Assignment.make()
        let c = Course.make()
        Color.make(["canvasContextID": c.canvasContextID])

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(resultingSubtitle, c.name)
        XCTAssertEqual(resultingBackgroundColor, UIColor.red)
    }

    func testLoadAssignment() {
        //  given
        Course.make()
        let expected = Assignment.make([ "submission": Submission.make() ])

        //  when
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        //  then
        XCTAssert(resultingAssignment === expected)
        XCTAssertEqual(presenter!.userID!, expected.submission!.userID)
    }

    func testBaseURLWithNilFragment() {
        let expected = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
        Assignment.make(["htmlURL": expected])
        Course.make()
        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: nil)

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(resultingBaseURL, expected)
    }

    func testBaseURLWithFragment() {
        let url = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
        let fragment = "fragment"
        Assignment.make(["htmlURL": url])
        Course.make()
        let expected = URL(string: "https://canvas.instructure.com/courses/1/assignments/1#fragment")!

        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: fragment)

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(resultingBaseURL?.absoluteString, expected.absoluteString)
    }

    func testBaseURLWithEmptyFragment() {
        let expected = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
        let fragment = ""
        Assignment.make(["htmlURL": expected])
        Course.make()
        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: fragment)

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(resultingBaseURL?.absoluteString, expected.absoluteString)
    }

    func testUseCaseFetchesData() {
        //  given
        Course.make()
        let expected = Assignment.make()

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)

        //  then
        XCTAssertEqual(resultingAssignment?.name, expected.name)
    }

    func testRoutesToSubmission() {
        Course.make()
        Assignment.make([ "id": "1", "submission": Submission.make([ "userID": "2" ]) ])

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)

        let router = env.router as? TestRouter

        presenter.routeToSubmission(view: UIViewController())
        XCTAssertEqual(router?.calls.last?.0, .parse("/courses/1/assignments/1/submissions/2"))
    }

    func testRoute() {
        let url = URL(string: "somewhere")!
        let controller = UIViewController()
        let router = env.router as? TestRouter
        XCTAssertTrue(presenter.route(to: url, from: controller))
        XCTAssertEqual(router?.calls.last?.0, .parse(url))
    }

    func testRouteFile() {
        let url = URL(string: "/course/1/files/2")!
        let controller = UIViewController()
        let router = env.router as? TestRouter
        XCTAssertTrue(presenter.route(to: url, from: controller))
        XCTAssertEqual(router?.calls.last?.0, .parse("/course/1/files/2?courseID=1&assignmentID=1"))
    }

    func testAssignmentAsAssignmentDetailsViewModel() {
        let assignment: Assignment = Assignment.make([
            "submission": Submission.make(["scoreRaw": 100, "grade": "A"]),
        ])
        XCTAssertEqual(assignment.viewableScore, 100)
        XCTAssertEqual(assignment.viewableGrade, "A")
    }
}

extension AssignmentDetailsPresenterTests: AssignmentDetailsViewProtocol {
    func open(_ url: URL) {}

    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {}

    func showSubmitAssignmentButton(title: String?) {
        resultingButtonTitle = title
    }

    func update(assignment: Assignment, quiz: Quiz?, baseURL: URL?) {
        resultingAssignment = assignment
        resultingBaseURL = baseURL
        resultingQuiz = quiz
        expectation.fulfill()
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }

    func updateNavBar(subtitle: String?, backgroundColor: UIColor?) {
        resultingSubtitle = subtitle
        resultingBackgroundColor = backgroundColor
    }
}
