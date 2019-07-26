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
    var presentedView: UIViewController?
    var expectation = XCTestExpectation(description: "expectation")
    var resultingButtonTitle: String?
    var navigationController: UINavigationController?
    var pageViewLogger: MockPageViewLogger = MockPageViewLogger()

    class MockButton: SubmissionButtonPresenter {
        var submitted = false
        override func submitAssignment(_ assignment: Assignment, button: UIView) {
            submitted = true
        }
    }
    lazy var mockButton = MockButton(view: self, assignmentID: "1")

    override func setUp() {
        super.setUp()
        pageViewLogger = MockPageViewLogger()
        env.pageViewLogger = pageViewLogger
        expectation = XCTestExpectation(description: "expectation")
        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: "target")
        presenter.submissionButtonPresenter = mockButton
    }

    func testLoadCourse() {
        //  given
        Assignment.make()
        let c = Course.make()
        Color.make(canvasContextID: c.canvasContextID)

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(resultingSubtitle, c.name)
        XCTAssertEqual(resultingBackgroundColor, UIColor.red)
    }

    func testLoadAssignment() {
        //  given
        Course.make()
        let expected = Assignment.make()

        //  when
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        //  then
        XCTAssert(resultingAssignment === expected)
        XCTAssertEqual(presenter!.userID!, expected.submission!.userID)
    }

    func testBaseURLWithNilFragment() {
        let expected = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
        Assignment.make(from: .make(html_url: expected))
        Course.make()
        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: nil)

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(resultingBaseURL, expected)
    }

    func testBaseURLWithFragment() {
        let url = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
        let fragment = "fragment"
        Assignment.make(from: .make(html_url: url))
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
        Assignment.make(from: .make(html_url: expected))
        Course.make()
        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: fragment)

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(resultingBaseURL?.absoluteString, expected.absoluteString)
    }

    func testUseCaseFetchesData() {
        //  given
        Course.make()
        Quiz.make()
        let expected = Assignment.make(from: .make(quiz_id: "1"))

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)

        //  then
        XCTAssertEqual(resultingAssignment?.name, expected.name)
    }

    func testRoutesToSubmission() {
        Course.make()
        Assignment.make(from: .make(id: "1", submission: .make(user_id: "2")))

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

    func testSubmit() {
        presenter.submit(button: UIView())
        XCTAssertFalse(mockButton.submitted)

        Assignment.make()
        presenter.refresh()
        presenter.submit(button: UIView())
        XCTAssertTrue(mockButton.submitted)
    }

    func testViewFileSubmission() {
        presenter.viewFileSubmission()
        XCTAssertNil(presentedView)

        Assignment.make()
        presenter.refresh()
        presenter.viewFileSubmission()
        XCTAssertNotNil(presentedView)
    }

    func testArcIDNone() {
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .pending)
        Assignment.make()
        Course.make()
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 0.5)
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .none)
    }

    func testArcIDSome() {
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .pending)
        Assignment.make()
        Course.make()
        ExternalTool.make(from: .make(id: "4", domain: "arc.instructure.com"), forCourse: "1")
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 0.5)
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .some("4"))
    }

    func testDueSectionIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue( presenter.dueSectionIsHidden() )
    }

    func testDueSectionNotHiddenAfterAvailability() {
        setupIsHiddenTest(lockStatus: .after)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse( presenter.dueSectionIsHidden() )
    }

    func testDueSectionNotHidden() {
        setupIsHiddenTest(lockStatus: .unlocked)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse( presenter.dueSectionIsHidden() )
    }

    func testLockedSectionIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse( presenter.lockedSectionIsHidden() )
        XCTAssertFalse( presenter.lockedIconContainerViewIsHidden() )
    }

    func testLockedSectionNotHiddenAfterAvailability() {
        setupIsHiddenTest(lockStatus: .after)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse( presenter.lockedSectionIsHidden() )
        XCTAssertTrue( presenter.lockedIconContainerViewIsHidden() )
    }

    func testLockedSectionNotHidden() {
        setupIsHiddenTest(lockStatus: .unlocked)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue( presenter.lockedSectionIsHidden() )
        XCTAssertTrue( presenter.lockedIconContainerViewIsHidden() )
    }

    func testFileTypesIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(presenter.assignments.first?.hasFileTypes ?? false)
        XCTAssertTrue( presenter.fileTypesSectionIsHidden() )
    }

    func testFileTypesSectionNotHiddenAfterAvailability() {
        setupIsHiddenTest(lockStatus: .after)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(presenter.assignments.first?.hasFileTypes ?? false)
        XCTAssertFalse( presenter.fileTypesSectionIsHidden() )
    }

    func testFileTypesSectionNotHidden() {
        setupIsHiddenTest(lockStatus: .unlocked)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(presenter.assignments.first?.hasFileTypes ?? false)
        XCTAssertFalse( presenter.fileTypesSectionIsHidden() )
    }

    func testSubmissionTypesIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue( presenter.submissionTypesSectionIsHidden() )
    }

    func testSubmissionTypesSectionNotHiddenAfterAvailability() {
        setupIsHiddenTest(lockStatus: .after)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse( presenter.submissionTypesSectionIsHidden() )
    }

    func testSubmissionTypesSectionNotHidden() {
        setupIsHiddenTest(lockStatus: .unlocked)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse( presenter.submissionTypesSectionIsHidden() )
    }

    func testGradesSectionIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue( presenter.gradesSectionIsHidden() )
    }

    func testGradesSectionNotHiddenAfterAvailability() {
        Course.make()
        Assignment.make(from: .make(submission: APISubmission.make(workflow_state: .graded), unlock_at: Date().addYears(-1), locked_for_user: true, lock_explanation: "this is locked"))
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse( presenter.gradesSectionIsHidden() )
    }

    func testGradesSectionNotHidden() {
        Course.make()
        Assignment.make(from: .make(submission: APISubmission.make(workflow_state: .graded)))
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse( presenter.gradesSectionIsHidden() )
    }

    func testViewSubmissionButtonSectionIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue( presenter.viewSubmissionButtonSectionIsHidden() )
    }

    func testViewSubmissionButtonSectionNotHiddenAfterAvailability() {
        setupIsHiddenTest(lockStatus: .after)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse( presenter.viewSubmissionButtonSectionIsHidden() )
    }

    func testViewSubmissionButtonSectionNotHidden() {
        setupIsHiddenTest(lockStatus: .unlocked)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse( presenter.viewSubmissionButtonSectionIsHidden() )
    }

    func testDescriptionSectionIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue( presenter.descriptionIsHidden() )
    }

    func testDescriptionSectionNotHiddenAfterAvailability() {
        setupIsHiddenTest(lockStatus: .after)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse( presenter.descriptionIsHidden() )
    }

    func testDescriptionSectionNotHidden() {
        setupIsHiddenTest(lockStatus: .unlocked)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse( presenter.descriptionIsHidden() )
    }

    func testSubmitAssignmentButtonIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue( presenter.submitAssignmentButtonIsHidden() )
    }

    func testSubmitAssignmentButtonNotHiddenAfterAvailability() {
        setupIsHiddenTest(lockStatus: .after)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse( presenter.submitAssignmentButtonIsHidden() )
    }

    func testSubmitAssignmentButtonNotHidden() {
        setupIsHiddenTest(lockStatus: .unlocked)
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse( presenter.submitAssignmentButtonIsHidden() )
    }

    func testPostsViewCompletedRequirement() {
        let expectation = XCTestExpectation(description: "notification")
        var notification: Notification?
        let token = NotificationCenter.default.addObserver(forName: .CompletedModuleItemRequirement, object: nil, queue: nil) {
            notification = $0
            expectation.fulfill()
        }
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 0.5)
        XCTAssertNotNil(notification)
        XCTAssertEqual(notification?.userInfo?["requirement"] as? ModuleItemCompletionRequirement, .view)
        XCTAssertEqual(notification?.userInfo?["moduleItem"] as? ModuleItemType, .assignment("1"))
        XCTAssertEqual(notification?.userInfo?["courseID"] as? String, "1")
        NotificationCenter.default.removeObserver(token)
    }

    func testSubmitAssignmentButtonIsHiddenWhenNotSubmittable() {
        Course.make()
        Assignment.make(from: .make(submission_types: [ .none ]))
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(presenter.submitAssignmentButtonIsHidden())
    }

    func testSubmitAssignmentButtonHiddenForExcused() {
        Course.make()
        Assignment.make(from: .make(submission: APISubmission.make(excused: true, workflow_state: .graded), submission_types: [ .online_text_entry ]))
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(presenter.submitAssignmentButtonIsHidden())
    }

    func setupIsHiddenTest(lockStatus: LockStatus) {
        Course.make()
        switch lockStatus {
        case .unlocked:
            Assignment.make(from: .make(submission_types: [ .online_upload ], allowed_extensions: ["png"]))
        case .before:
            Assignment.make(from: .make(submission_types: [ .online_upload ], allowed_extensions: ["png"], unlock_at: Date().addYears(1), locked_for_user: true, lock_explanation: "this is locked"))
        case .after:
            Assignment.make(from: .make(submission_types: [ .online_upload ], allowed_extensions: ["png"], unlock_at: Date().addYears(-1), locked_for_user: true, lock_explanation: "this is locked"))
        }
        presenter.viewIsReady()
    }

    func testPageViewLogging() {
        let c = Course.make()
        let a = Assignment.make()
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)

        presenter.viewDidAppear()
        presenter.viewDidDisappear()

        XCTAssertEqual(pageViewLogger.eventName, "/courses/\(c.id)/assignments/\(a.id)")
    }

    func testAssignmentDescription() {
        let a = Assignment.make()
        XCTAssertEqual(presenter.assignmentDescription(), a.descriptionHTML)
    }

    func testAssignmentDescriptionThatIsEmpty() {
        Assignment.make(from: .make(description: ""))
        XCTAssertEqual(presenter.assignmentDescription(), "No Content")
    }
}

extension AssignmentDetailsPresenterTests: AssignmentDetailsViewProtocol {
    func open(_ url: URL) {}

    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        presentedView = viewControllerToPresent
    }

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
