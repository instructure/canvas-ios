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
import Core
import TestsFoundation

class AssignmentDetailsPresenterTests: PersistenceTestCase {

    var resultingError: NSError?
    var resultingAssignment: AssignmentDetailsViewModel?
    var resultingBaseURL: URL?
    var resultingSubtitle: String?
    var resultingBackgroundColor: UIColor?
    var resultingSubmissionTypes: [SubmissionType]?
    var presenter: AssignmentDetailsPresenter!
    var expectation = XCTestExpectation(description: "expectation")
    var resultingButtonTitle: String?
    var navigationController: UINavigationController?

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: "target")
    }

    func testLoadCourse() {
        //  given
        let c = Course.make()
        Color.make(["canvasContextID": c.canvasContextID])

        presenter.viewIsReady()
        XCTAssertEqual(resultingSubtitle, c.name)
        XCTAssertEqual(resultingBackgroundColor, UIColor.red)
    }

    func testLoadAssignment() {
        //  given
        let expected = Assignment.make([ "submission": Submission.make() ])

        //  when
        presenter.viewIsReady()

        //  then
        XCTAssert(resultingAssignment as! Assignment === expected)
        XCTAssertEqual(presenter!.userID!, expected.submission!.userID)
    }

    func testBaseURLWithNilFragment() {
        let expected = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
        Assignment.make(["htmlURL": expected])
        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: nil)

        presenter.viewIsReady()

        XCTAssertEqual(resultingBaseURL, expected)
    }

    func testBaseURLWithFragment() {
        let url = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
        let fragment = "fragment"
        Assignment.make(["htmlURL": url])
        let expected = URL(string: "https://canvas.instructure.com/courses/1/assignments/1#fragment")!

        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: fragment)

        presenter.viewIsReady()
        XCTAssertEqual(resultingBaseURL?.absoluteString, expected.absoluteString)
    }

    func testBaseURLWithEmptyFragment() {
        let expected = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
        let fragment = ""
        Assignment.make(["htmlURL": expected])
        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: fragment)

        presenter.viewIsReady()

        XCTAssertEqual(resultingBaseURL?.absoluteString, expected.absoluteString)
    }

    func testUseCaseFetchesData() {
        //  given
        let expected = Assignment.make()

        presenter.viewIsReady()

        //  then
        XCTAssertEqual(resultingAssignment?.name, expected.name)
    }

    func testRoutesToSubmission() {
        Assignment.make([ "id": "1", "submission": Submission.make([ "userID": "2" ]) ])

        presenter.viewIsReady()

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
        let assignment: AssignmentDetailsViewModel = Assignment.make([
            "submission": Submission.make(["scoreRaw": 100, "grade": "A"]),
        ])
        XCTAssertEqual(assignment.viewableScore, 100)
        XCTAssertEqual(assignment.viewableGrade, "A")
    }

    func testShowSubmitAssignmentButton() {
        //  given
        let a = Assignment.make()
        a.unlockAt = Date().addDays(-1)
        a.lockAt = Date().addDays(1)
        a.lockedForUser = false
        a.submissionTypes = [.online_upload]

        let c = Course.make(["enrollments": Set([Enrollment.make()])])

        //  when
        presenter.showSubmitAssignmentButton(assignment: a, course: c)

        //  then
        XCTAssertEqual(resultingButtonTitle, "Submit Assignment")
    }

    @discardableResult
    func assignmentSetupForSubmissionsTypeTests(_ types: [SubmissionType]) -> Assignment {
        let subTypes = Array(types.map { $0.rawValue })

        let assignment = Assignment.make(["submissionTypesRaw": subTypes])
        Course.make(["enrollments": Set([Enrollment.make()])])

        presenter.loadData()
        return assignment
    }

    func testShowSubmitAssignmentButtonMultipleAttempts() {
        //  given
        let a = Assignment.make()
        a.unlockAt = Date().addDays(-1)
        a.lockAt = Date().addDays(1)
        a.lockedForUser = false
        a.submissionTypes = [.online_upload]
        a.submission = Submission.make()

        let c = Course.make(["enrollments": Set([Enrollment.make()])])

        //  when
        presenter.showSubmitAssignmentButton(assignment: a, course: c)

        //  then
        XCTAssertEqual(resultingButtonTitle, "Resubmit Assignment")
    }

    func testSubmitOnlineUploadCancelsFileUpload() {
        let assignment = Assignment.make(["id": "1"])
        FileSubmission.make(["assignment": assignment])
        let expectation = BlockExpectation(description: "files refresh") {
            self.databaseClient.refresh()
            return assignment.fileSubmission == nil
        }

        presenter.submit(.online_upload, from: UIViewController())
        queue.waitUntilAllOperationsAreFinished()

        wait(for: [expectation], timeout: 1)
    }

    func testSubmitOnlineUpload() {
        let assignment = Assignment.make(["id": "1"])
        FileSubmission.make(["assignment": assignment])
        let expectation = BlockExpectation(description: "main queue") {
            return self.router.lastRoutedTo(.assignmentFileUpload(courseID: "1", assignmentID: "1"))
        }

        let vc = UIViewController()
        presenter.submit(.online_upload, from: vc)

        wait(for: [expectation], timeout: 1)
    }

    func testSubmitOnlineURL() {
        Assignment.make(["id": "1"])

        presenter.submit(.online_url, from: UIViewController())

        XCTAssert(router.lastRoutedTo(.assignmentUrlSubmission(courseID: "1", assignmentID: "1", userID: "")))
    }

    func testSubmitAssignmentAutomaticallyDoesOnlySubmissionType() {
        let assignment = Assignment.make(["id": "1"])
        assignment.submissionTypes = [.online_upload]

        let expectation = BlockExpectation(description: "main queue") {
            return self.router.lastRoutedTo(.assignmentFileUpload(courseID: assignment.courseID, assignmentID: "1"))
        }

        presenter.viewIsReady()
        let viewController = UIViewController()
        presenter.submitAssignment(from: viewController)

        wait(for: [expectation], timeout: 5)
    }

    func testSubmitAssignmentSendsBackSupportedSubmissionTypes() {
        let assignment = Assignment.make(["id": "1"])
        assignment.submissionTypes = [.online_upload, .online_url, .on_paper]

        presenter.viewIsReady()
        let viewController = UIViewController()
        presenter.submitAssignment(from: viewController)

        XCTAssertEqual(resultingSubmissionTypes, [.online_upload, .online_url])
    }

    func testViewFileSubmission() {
        Assignment.make(["id": "1"])

        presenter.viewFileSubmission(from: UIViewController())

        XCTAssert(router.lastRoutedTo(.assignmentFileUpload(courseID: "1", assignmentID: "1")))
    }
}

extension AssignmentDetailsPresenterTests: AssignmentDetailsViewProtocol {
    func showSubmitAssignmentButton(title: String?) {
        resultingButtonTitle = title
    }

    func chooseSubmissionType(_ types: [SubmissionType]) {
        resultingSubmissionTypes = types
    }

    func update(assignment: AssignmentDetailsViewModel, baseURL: URL?) {
        resultingAssignment = assignment
        resultingBaseURL = baseURL
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
