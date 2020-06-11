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

class AssignmentDetailsPresenterTests: StudentTestCase {
    var resultingError: NSError?
    var resultingAssignment: Assignment?
    var resultingQuiz: Quiz?
    var resultingBaseURL: URL?
    var resultingSubtitle: String?
    var resultingBackgroundColor: UIColor?
    var presenter: AssignmentDetailsPresenter!
    var presentedView: UIViewController?
    var resultingButtonTitle: String?
    var navigationController: UINavigationController?
    var pageViewLogger: MockPageViewLogger = MockPageViewLogger()
    var onUpdate: (() -> Void)?

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
        env.mockStore = true
        env.pageViewLogger = pageViewLogger
        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: "target")
        presenter.submissionButtonPresenter = mockButton
    }

    func testUseCasesSetupProperly() {
        XCTAssertEqual(presenter.courses.useCase.courseID, presenter.courseID)

        XCTAssertEqual(presenter.assignments.useCase.courseID, presenter.courseID)
        XCTAssertEqual(presenter.assignments.useCase.assignmentID, presenter.assignmentID)
        XCTAssertEqual(presenter.assignments.useCase.include, [.submission])

        XCTAssertEqual(presenter.arc.useCase.courseID, presenter.courseID)
    }

    func testLoadCourse() {
        let c = Course.make()
        Assignment.make()
        presenter.courses.eventHandler()
        XCTAssertEqual(resultingSubtitle, c.name)
    }

    func testLoadColor() {
        let c = Course.make()
        Assignment.make()
        ContextColor.make(canvasContextID: c.canvasContextID)

        presenter.colors.eventHandler()
        XCTAssertEqual(resultingBackgroundColor, UIColor.red)
    }

    func testLoadAssignment() {
        Course.make()
        let expected = Assignment.make()

        presenter.assignments.eventHandler()

        XCTAssertEqual(resultingAssignment, expected)
        XCTAssertEqual(presenter!.userID!, expected.submission!.userID)
    }

    func testLoadQuiz() {
        Course.make()
        Assignment.make(from: .make(quiz_id: "1"))
        let quiz = Quiz.make(from: .make(id: "1"))
        quiz.submission = QuizSubmission.make()
        try! databaseClient.save()

        presenter.update()
        let quizStore = presenter.quizzes as! TestStore

        wait(for: [quizStore.refreshExpectation], timeout: 0.1)

        presenter.quizzes?.eventHandler()
        XCTAssertEqual(resultingQuiz, quiz)
        XCTAssertEqual(resultingQuiz?.submission, quiz.submission)
    }

    func testViewIsReady() {
        presenter.viewIsReady()
        let coursesStore = presenter.courses as! TestStore
        let assignmentsStore = presenter.assignments as! TestStore
        let colorsStore = presenter.colors as! TestStore
        let arcStore = presenter.arc as! TestStore

        presenter.viewIsReady()
        wait(for: [coursesStore.refreshExpectation, assignmentsStore.refreshExpectation, colorsStore.refreshExpectation, arcStore.refreshExpectation], timeout: 0.1)
    }

    func testBaseURLWithNilFragment() {
        Course.make()
        let expected = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
        Assignment.make(from: .make(html_url: expected))

        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: nil)
        presenter.assignments.eventHandler()

        XCTAssertEqual(resultingBaseURL, expected)
    }

    func testBaseURLWithFragment() {
        Course.make()
        let url = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
        let fragment = "fragment"
        Assignment.make(from: .make(html_url: url))
        let expected = URL(string: "https://canvas.instructure.com/courses/1/assignments/1#fragment")!

        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: fragment)

        presenter.assignments.eventHandler()
        XCTAssertEqual(resultingBaseURL?.absoluteString, expected.absoluteString)
    }

    func testBaseURLWithEmptyFragment() {
        Course.make()

        let expected = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
        let fragment = ""
        Assignment.make(from: .make(html_url: expected))
        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: fragment)

        presenter.assignments.eventHandler()
        XCTAssertEqual(resultingBaseURL?.absoluteString, expected.absoluteString)
    }

    func testRoutesToSubmission() {
        Course.make()
        Assignment.make(from: .make(id: "1", submission: .make(user_id: "2")))

        // must go through the update method in order to set the userID to the user id
        // from the submission
        presenter.assignments.eventHandler()
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

        presenter.submit(button: UIView())
        XCTAssertTrue(mockButton.submitted)
    }

    func testViewFileSubmission() {
        presenter.viewFileSubmission()
        XCTAssertNil(presentedView)

        Assignment.make()

        presenter.viewFileSubmission()
        XCTAssertNotNil(presentedView)
    }

    func testArcIDNone() {
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .pending)

        presenter.arc.eventHandler()

        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .none)
    }

    func testArcIDSome() {
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .pending)

        ExternalTool.make(from: .make(id: "4", domain: "arc.instructure.com"))
        presenter.arc.eventHandler()

        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .some("4"))
    }

    func testDueSectionIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        XCTAssertTrue( presenter.dueSectionIsHidden() )
    }

    func testDueSectionNotHiddenAfterAvailability() {
        setupIsHiddenTest(lockStatus: .after)
        XCTAssertFalse( presenter.dueSectionIsHidden() )
    }

    func testDueSectionNotHidden() {
        setupIsHiddenTest(lockStatus: .unlocked, lockedForUser: false)
        XCTAssertFalse( presenter.dueSectionIsHidden() )
    }

    func testLockedSectionIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        XCTAssertFalse( presenter.lockedSectionIsHidden() )
        XCTAssertFalse( presenter.lockedIconContainerViewIsHidden() )
    }

    func testLockedSectionNotHiddenAfterAvailability() {
        setupIsHiddenTest(lockStatus: .after)
        XCTAssertFalse( presenter.lockedSectionIsHidden() )
        XCTAssertTrue( presenter.lockedIconContainerViewIsHidden() )
    }

    func testLockedSectionNotHidden() {
        setupIsHiddenTest(lockStatus: .unlocked, lockedForUser: false)
        XCTAssertTrue( presenter.lockedSectionIsHidden() )
        XCTAssertTrue( presenter.lockedIconContainerViewIsHidden() )
    }

    func testFileTypesIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        XCTAssertTrue(presenter.assignments.first?.hasFileTypes ?? false)
        XCTAssertTrue( presenter.fileTypesSectionIsHidden() )
    }

    func testFileTypesSectionNotHiddenAfterAvailability() {
        setupIsHiddenTest(lockStatus: .after)
        XCTAssertTrue(presenter.assignments.first?.hasFileTypes ?? false)
        XCTAssertFalse( presenter.fileTypesSectionIsHidden() )
    }

    func testFileTypesSectionNotHidden() {
        setupIsHiddenTest(lockStatus: .unlocked, lockedForUser: false)
        XCTAssertTrue(presenter.assignments.first?.hasFileTypes ?? false)
        XCTAssertFalse( presenter.fileTypesSectionIsHidden() )
    }

    func testSubmissionTypesIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        XCTAssertTrue( presenter.submissionTypesSectionIsHidden() )
    }

    func testSubmissionTypesSectionNotHiddenAfterAvailability() {
        setupIsHiddenTest(lockStatus: .after)
        XCTAssertFalse( presenter.submissionTypesSectionIsHidden() )
    }

    func testSubmissionTypesSectionNotHidden() {
        setupIsHiddenTest(lockStatus: .unlocked, lockedForUser: false)
        XCTAssertFalse( presenter.submissionTypesSectionIsHidden() )
    }

    func testGradesSectionIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        XCTAssertTrue( presenter.gradesSectionIsHidden() )
    }

    func testGradesSectionNotHiddenAfterAvailability() {
        Assignment.make(from: .make(submission: APISubmission.make(workflow_state: .graded), unlock_at: Date().addYears(-1), locked_for_user: true, lock_explanation: "this is locked"))
        XCTAssertFalse( presenter.gradesSectionIsHidden() )
    }

    func testGradesSectionNotHidden() {
        Assignment.make(from: .make(submission: APISubmission.make(workflow_state: .graded)))
        XCTAssertFalse( presenter.gradesSectionIsHidden() )
    }

    func testViewSubmissionButtonSectionIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        XCTAssertTrue( presenter.viewSubmissionButtonSectionIsHidden() )
    }

    func testViewSubmissionButtonSectionNotHiddenAfterAvailability() {
        setupIsHiddenTest(lockStatus: .after)
        XCTAssertFalse( presenter.viewSubmissionButtonSectionIsHidden() )
    }

    func testViewSubmissionButtonSectionNotHidden() {
        setupIsHiddenTest(lockStatus: .unlocked, lockedForUser: false)
        XCTAssertFalse( presenter.viewSubmissionButtonSectionIsHidden() )
    }

    func testDescriptionSectionIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        XCTAssertTrue( presenter.descriptionIsHidden() )
    }

    func testDescriptionSectionNotHiddenAfterAvailability() {
        setupIsHiddenTest(lockStatus: .after)
        XCTAssertFalse( presenter.descriptionIsHidden() )
    }

    func testDescriptionSectionNotHidden() {
        setupIsHiddenTest(lockStatus: .unlocked, lockedForUser: false)
        XCTAssertFalse( presenter.descriptionIsHidden() )
    }

    func testSubmitAssignmentButtonIsHiddenBeforeAvailability() {
        setupIsHiddenTest(lockStatus: .before)
        XCTAssertTrue( presenter.submitAssignmentButtonIsHidden() )
    }

    func testSubmitAssignmentButtonNotHiddenAfterAvailability() {
        setupIsHiddenTest(lockStatus: .after, lockedForUser: false)
        XCTAssertFalse( presenter.submitAssignmentButtonIsHidden() )
    }

    func testSubmitAssignmentButtonNotHiddenAfterAvailabilityWhenLockedForUser() {
        setupIsHiddenTest(lockStatus: .after, lockedForUser: true)
        XCTAssertTrue( presenter.submitAssignmentButtonIsHidden() )
    }

    func testSubmitAssignmentButtonNotHidden() {
        setupIsHiddenTest(lockStatus: .unlocked, lockedForUser: false)
        XCTAssertFalse( presenter.submitAssignmentButtonIsHidden() )
    }

    func testSubmitAssignmentButtonIsHiddenWhenLockedForUser() {
        Assignment.make(from: .make(submission_types: [ .online_upload ], allowed_extensions: ["png"], locked_for_user: true))
        XCTAssertTrue( presenter.submitAssignmentButtonIsHidden() )
    }

    func testPostsViewCompletedRequirement() {
        Course.make()
        Assignment.make()
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
        Assignment.make(from: .make(submission_types: [ .none ]))
        XCTAssertTrue(presenter.submitAssignmentButtonIsHidden())
    }

    func testSubmitAssignmentButtonHiddenForExcused() {
        Assignment.make(from: .make(submission: APISubmission.make(excused: true, workflow_state: .graded), submission_types: [ .online_text_entry ]))
        XCTAssertTrue(presenter.submitAssignmentButtonIsHidden())
    }

    func setupIsHiddenTest(lockStatus: LockStatus, lockedForUser: Bool = true) {
        switch lockStatus {
        case .unlocked:
            Assignment.make(from: .make(submission_types: [ .online_upload ], allowed_extensions: ["png"], locked_for_user: lockedForUser))
        case .before:
            Assignment.make(from: .make(submission_types: [ .online_upload ],
                                        allowed_extensions: ["png"],
                                        unlock_at: Date().addYears(1),
                                        locked_for_user: lockedForUser,
                                        lock_explanation: "this is locked"))
        case .after:
            Assignment.make(from: .make(submission_types: [ .online_upload ],
                                        allowed_extensions: ["png"],
                                        unlock_at: Date().addYears(-1),
                                        locked_for_user: lockedForUser,
                                        lock_explanation: "this is locked"))
        }
    }

    func testPageViewLogging() {
        presenter.viewDidAppear()
        presenter.viewDidDisappear()

        XCTAssertEqual(pageViewLogger.eventName, "/courses/\(presenter.courseID)/assignments/\(presenter.assignmentID)")
    }

    func testAssignmentDescription() {
        let a = Assignment.make()
        XCTAssertEqual(presenter.assignmentDescription(), a.details)
    }

    func testAssignmentDescriptionThatIsEmpty() {
        Assignment.make(from: .make(description: ""))
        XCTAssertEqual(presenter.assignmentDescription(), "No Content")
    }

    func testCreatesSubmissionWhenOnlineUploadFinishes() {
        // setup the notification listening
        presenter.viewIsReady()

        Course.make()
        Assignment.make(from: .make(submission: .make(submitted_at: nil, workflow_state: .unsubmitted)))

        NotificationCenter.default.post(name: UploadManager.AssignmentSubmittedNotification, object: nil, userInfo: [
            "assignmentID": "1",
            "submission": APISubmission.make(),
        ])
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
    }

    func testUpdatesWhenOnlineUploadStateChanges() throws {
        Course.make()
        let assignment = Assignment.make()

        let url = URL.temporaryDirectory.appendingPathComponent("assignment-details.txt")
        FileManager.default.createFile(atPath: url.path, contents: "test".data(using: .utf8), attributes: nil)
        let file = try UploadManager.shared.add(url: url, batchID: "assignment-\(assignment.id)")

        let expectation = XCTestExpectation(description: "update was called after online upload updated")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = false
        onUpdate = {
            expectation.fulfill()
        }

        presenter.assignments.eventHandler()

        file.uploadError = "it failed"
        try UploadManager.shared.viewContext.save()
        file.uploadError = "im telling you, IT FAILED!!"
        try UploadManager.shared.viewContext.save()
        wait(for: [expectation], timeout: 0.1)
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
        onUpdate?()
    }

    func showAlert(title: String?, message: String?) {}

    func showError(_ error: Error) {
        resultingError = error as NSError
    }

    func updateNavBar(subtitle: String?, backgroundColor: UIColor?) {
        resultingSubtitle = subtitle
        resultingBackgroundColor = backgroundColor
    }
}
