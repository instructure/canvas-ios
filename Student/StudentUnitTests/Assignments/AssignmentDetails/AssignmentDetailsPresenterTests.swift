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
        env.pageViewLogger = pageViewLogger
        expectation = XCTestExpectation(description: "expectation")
        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: "target")
        presenter.submissionButtonPresenter = mockButton
    }

    @discardableResult
    func mockAssignment(_ assignment: APIAssignment = .make(id: "1", course_id: "1")) -> APIAssignment {
        api.mock(GetAssignmentRequest(courseID: assignment.course_id.value, assignmentID: assignment.id.value, include: [.submission]), value: assignment)
        return assignment
    }

    @discardableResult
    func mockCourse(_ course: APICourse = .make(id: "1")) -> APICourse {
        api.mock(GetCourseRequest(courseID: course.id.value, include: GetCourseRequest.defaultIncludes), value: course)
        return course
    }

    func mockColor(_ course: APICourse = .make(id: "1"), color: String = "#ff0000") {
        api.mock(GetCustomColorsRequest(), value: APICustomColors(custom_colors: ["course_\(course.id.value)": color]))
    }

    func mockArc(_ tool: [APIExternalTool] = [], course: APICourse = .make(id: "1")) {
        api.mock(GetExternalToolsRequest(context: ContextModel(.course, id: course.id.value), includeParents: true, perPage: 99), value: tool)
    }

    @discardableResult
    func mockQuiz(_ quiz: APIQuiz = .make(id: "1"), course: APICourse = .make(id: "1")) -> APIQuiz {
        api.mock(GetQuizRequest(courseID: course.id.value, quizID: quiz.id.value), value: quiz)
        return quiz
    }

    func mockQuizSubmission(_ quizSubmissions: [APIQuizSubmission] = [.make(quiz_id: "1")], course: APICourse = .make(id: "1")) {
        api.mock(GetQuizSubmissionRequest(courseID: course.id.value, quizID: quizSubmissions[0].quiz_id.value), value: GetQuizSubmissionRequest.Response(quiz_submissions: quizSubmissions))
    }

    func testLoadCourse() {
        //  given
        let c = mockCourse()
        mockColor(c)
        mockAssignment()
        mockArc()

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(resultingSubtitle, c.name)
        XCTAssertEqual(resultingBackgroundColor, UIColor.red)
    }

    func testLoadAssignment() {
        //  given
        mockCourse()
        let expected = mockAssignment()
        mockColor()
        mockArc()

        //  when
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        //  then
        XCTAssertEqual(resultingAssignment!.id, expected.id.value)
        XCTAssertEqual(presenter!.userID!, expected.submission!.values[0].user_id.value)
    }

    func testBaseURLWithNilFragment() {
        mockCourse()
        mockColor()
        mockArc()
        let expected = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
        mockAssignment(.make(html_url: expected))

        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: nil)

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(resultingBaseURL, expected)
    }

    func testBaseURLWithFragment() {
        mockCourse()
        mockColor()
        mockArc()
        let url = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
        let fragment = "fragment"
        mockAssignment(.make(html_url: url))
        let expected = URL(string: "https://canvas.instructure.com/courses/1/assignments/1#fragment")!

        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: fragment)

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(resultingBaseURL?.absoluteString, expected.absoluteString)
    }

    func testBaseURLWithEmptyFragment() {
        mockCourse()
        mockColor()
        mockArc()
        let expected = URL(string: "https://canvas.instructure.com/courses/1/assignments/1")!
        let fragment = ""
        mockAssignment(.make(html_url: expected))
        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: fragment)

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(resultingBaseURL?.absoluteString, expected.absoluteString)
    }

    func testUseCaseFetchesData() {
        //  given
        mockCourse()
        mockColor()
        mockArc()
        let expected = mockAssignment(.make(quiz_id: "1"))
        mockQuiz()
        mockQuizSubmission()

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)

        //  then
        XCTAssertEqual(resultingAssignment?.name, expected.name)
    }

    func testRoutesToSubmission() {
        mockCourse()
        mockColor()
        mockArc()
        mockAssignment(.make(id: "1", submission: .make(user_id: "2")))

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

        mockCourse()
        mockColor()
        mockArc()
        mockAssignment()

        presenter.refresh()
        wait(for: [expectation], timeout: 5)
        presenter.submit(button: UIView())
        XCTAssertTrue(mockButton.submitted)
    }

    func testViewFileSubmission() {
        presenter.viewFileSubmission()
        XCTAssertNil(presentedView)

        mockCourse()
        mockColor()
        mockArc()
        mockAssignment()

        presenter.refresh()
        wait(for: [expectation], timeout: 5)

        presenter.viewFileSubmission()
        XCTAssertNotNil(presentedView)
    }

    func testArcIDNone() {
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .pending)
        mockCourse()
        mockColor()
        mockArc()
        mockAssignment()

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 0.5)

        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .none)
    }

    func testArcIDSome() {
        XCTAssertEqual(presenter.submissionButtonPresenter.arcID, .pending)
        mockCourse()
        mockColor()
        mockArc([.make(id: "4", domain: "arc.instructure.com")])
        mockAssignment()

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 5)
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
        mockCourse()
        mockColor()
        mockArc()
        mockAssignment(.make(submission: APISubmission.make(workflow_state: .graded), unlock_at: Date().addYears(-1), locked_for_user: true, lock_explanation: "this is locked"))
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertFalse( presenter.gradesSectionIsHidden() )
    }

    func testGradesSectionNotHidden() {
        mockCourse()
        mockColor()
        mockArc()
        mockAssignment(.make(submission: APISubmission.make(workflow_state: .graded)))
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
        mockCourse()
        mockColor()
        mockArc()
        mockAssignment(.make(submission_types: [ .none ]))
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(presenter.submitAssignmentButtonIsHidden())
    }

    func testSubmitAssignmentButtonHiddenForExcused() {
        mockCourse()
        mockColor()
        mockArc()
        mockAssignment(.make(submission: APISubmission.make(excused: true, workflow_state: .graded), submission_types: [ .online_text_entry ]))
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(presenter.submitAssignmentButtonIsHidden())
    }

    func setupIsHiddenTest(lockStatus: LockStatus) {
        mockCourse()
        mockColor()
        mockArc()

        switch lockStatus {
        case .unlocked:
            mockAssignment(.make(submission_types: [ .online_upload ], allowed_extensions: ["png"]))
        case .before:
            mockAssignment(.make(submission_types: [ .online_upload ], allowed_extensions: ["png"], unlock_at: Date().addYears(1), locked_for_user: true, lock_explanation: "this is locked"))
        case .after:
            mockAssignment(.make(submission_types: [ .online_upload ], allowed_extensions: ["png"], unlock_at: Date().addYears(-1), locked_for_user: true, lock_explanation: "this is locked"))
        }
        presenter.viewIsReady()
    }

    func testPageViewLogging() {
        let c = mockCourse()
        mockColor()
        mockArc()
        let a = mockAssignment()
        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)

        presenter.viewDidAppear()
        presenter.viewDidDisappear()

        XCTAssertEqual(pageViewLogger.eventName, "/courses/\(c.id.value)/assignments/\(a.id.value)")
    }

    func testAssignmentDescription() {
        mockCourse()
        mockColor()
        mockArc()
        let a = mockAssignment()

        presenter.viewIsReady()
        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(presenter.assignmentDescription(), a.description)
    }

    func testAssignmentDescriptionThatIsEmpty() {
        mockCourse()
        mockColor()
        mockArc()
        mockAssignment()
        XCTAssertEqual(presenter.assignmentDescription(), "No Content")
    }

    func testCreatesSubmissionWhenOnlineUploadFinishes() {
        mockCourse()
        mockColor()
        mockArc()
        mockAssignment(.make(submission: nil))
        presenter.viewIsReady()

        wait(for: [expectation], timeout: 5)
        NotificationCenter.default.post(name: UploadManager.AssignmentSubmittedNotification, object: nil, userInfo: [
            "assignmentID": "1",
            "submission": APISubmission.make(),
        ])
        let submissions: [Submission] = databaseClient.fetch()
        XCTAssertEqual(submissions.count, 1)
    }

    func testUpdatesWhenOnlineUploadStateChanges() throws {
        mockCourse()
        mockColor()
        mockArc()
        let assignment = mockAssignment()

        let url = URL.temporaryDirectory.appendingPathComponent("assignment-details.txt")
        FileManager.default.createFile(atPath: url.path, contents: "test".data(using: .utf8), attributes: nil)
        let file = try UploadManager.shared.add(environment: env, url: url, batchID: "assignment-\(assignment.id.value)")
        presenter.viewIsReady()
        let expectation = XCTestExpectation(description: "update was called after online upload updated")
        expectation.expectedFulfillmentCount = 1
        expectation.assertForOverFulfill = false
        onUpdate = {
            expectation.fulfill()
        }
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
        if presenter.assignments.pending == false && presenter.colors.pending == false && presenter.courses.pending == false && presenter.arc.pending == false {
            expectation.fulfill()
        }
    }

    func showError(_ error: Error) {
        resultingError = error as NSError
    }

    func updateNavBar(subtitle: String?, backgroundColor: UIColor?) {
        resultingSubtitle = subtitle
        resultingBackgroundColor = backgroundColor
    }
}
