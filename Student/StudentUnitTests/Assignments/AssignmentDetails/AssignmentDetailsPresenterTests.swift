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
    var resultingSubmissionTypes: [SubmissionType]?
    var presenter: AssignmentDetailsPresenter!
    var expectation = XCTestExpectation(description: "expectation")
    var resultingButtonTitle: String?
    var navigationController: UINavigationController?
    var filePicker: FilePickerViewController?
    let fileUploader = MockFileUploader()
    var didChooseMediaRecordingType = false

    override func setUp() {
        super.setUp()
        expectation = XCTestExpectation(description: "expectation")
        presenter = AssignmentDetailsPresenter(env: env, view: self, courseID: "1", assignmentID: "1", fragment: "target")
        presenter.fileUploader = fileUploader
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

    func testShowSubmitAssignmentButton() {
        //  given
        let a = Assignment.make([
            "submission": Submission.make(["workflowStateRaw": "unsubmitted"]),
        ])
        a.unlockAt = Date().addDays(-1)
        a.lockAt = Date().addDays(1)
        a.lockedForUser = false
        a.submissionTypes = [.online_upload]

        let c = Course.make(["enrollments": Set([Enrollment.make()])])

        //  when
        presenter.showSubmitAssignmentButton(assignment: a, quiz: nil, course: c)

        //  then
        XCTAssertEqual(resultingButtonTitle, "Submit Assignment")
    }

    func testShowSubmitAssignmentButtonMultipleAttempts() {
        //  given
        let a = Assignment.make([
            "submission": Submission.make(["workflowStateRaw": "submitted"]),
        ])
        a.unlockAt = Date().addDays(-1)
        a.lockAt = Date().addDays(1)
        a.lockedForUser = false
        a.submissionTypes = [.online_upload]

        let c = Course.make(["enrollments": Set([Enrollment.make()])])

        //  when
        presenter.showSubmitAssignmentButton(assignment: a, quiz: nil, course: c)

        //  then
        XCTAssertEqual(resultingButtonTitle, "Resubmit Assignment")
    }

    func testShowSubmitAssignmentButtonExternalTool() {
        let a = Assignment.make()
        a.submissionTypes = [.external_tool]

        let c = Course.make(["enrollments": Set([Enrollment.make()])])

        presenter.showSubmitAssignmentButton(assignment: a, quiz: nil, course: c)
        XCTAssertEqual(resultingButtonTitle, "Launch External Tool")
    }

    func testShowSubmitAssignmentButtonDiscussion() {
        let a = Assignment.make()
        a.submissionTypes = [.discussion_topic]

        let c = Course.make(["enrollments": Set([Enrollment.make()])])

        presenter.showSubmitAssignmentButton(assignment: a, quiz: nil, course: c)
        XCTAssertEqual(resultingButtonTitle, "View Discussion")
    }

    func testShowSubmitAssignmentButtonQuiz() {
        let a = Assignment.make()
        a.submissionTypes = [.online_quiz]
        let q = Quiz.make()
        let c = Course.make(["enrollments": Set([Enrollment.make()])])

        presenter.showSubmitAssignmentButton(assignment: a, quiz: q, course: c)
        XCTAssertEqual(resultingButtonTitle, "Take Quiz")
    }

    func testSubmitSubmissionTypeOnlineUpload() {
        Assignment.make(["id": "1", "submissionTypesRaw": [SubmissionType.online_upload.rawValue]])
        presenter.viewIsReady()
        presenter.submit(.online_upload, from: UIViewController())
        XCTAssertNotNil(filePicker)
    }

    func testSubmitSubmissionTypeOnlineUploadEmptyExtensions() {
        Assignment.make(["id": "1", "submissionTypesRaw": [SubmissionType.online_upload.rawValue], "allowedExtensions": []])
        presenter.viewIsReady()
        presenter.submit(.online_upload, from: UIViewController())
        XCTAssertEqual(filePicker?.sources, [.files, .library, .camera])
    }

    func testSubmitOnlineUploadFilesOnly() {
        Assignment.make(["id": "1", "submissionTypesRaw": [SubmissionType.online_upload.rawValue], "allowedExtensions": ["txt"]])
        presenter.viewIsReady()
        presenter.submit(.online_upload, from: UIViewController())
        XCTAssertEqual(filePicker?.sources, [.files])
    }

    func testSubmitOnlineUploadImages() {
        Assignment.make(["id": "1", "submissionTypesRaw": [SubmissionType.online_upload.rawValue], "allowedExtensions": ["jpg"]])
        presenter.viewIsReady()
        presenter.submit(.online_upload, from: UIViewController())
        XCTAssertEqual(filePicker?.sources, [.files, .library, .camera])
    }

    func testSubmitSubmissionTypeMediaRecording() {
        let assignment = Assignment.make(["id": "1"])
        assignment.submissionTypes = [.media_recording]
        presenter.submit(.media_recording, from: UIViewController())
        XCTAssertTrue(didChooseMediaRecordingType)
    }

    func testSubmitOnlineURL() {
        Assignment.make(["id": "1"])

        presenter.submit(.online_url, from: UIViewController())

        XCTAssert(router.lastRoutedTo(.assignmentUrlSubmission(courseID: "1", assignmentID: "1", userID: "")))
    }

    func testSubmitAssignmentAutomaticallyDoesOnlySubmissionType() {
        let assignment = Assignment.make(["id": "1"])
        assignment.submissionTypes = [.online_text_entry]

        let expectation = BlockExpectation(description: "main queue") {
            return self.router.lastRoutedTo(.assignmentTextSubmission(courseID: assignment.courseID, assignmentID: "1", userID: ""))
        }

        presenter.viewIsReady()
        let viewController = UIViewController()
        presenter.submitAssignment(from: viewController)

        wait(for: [expectation], timeout: 5)
    }

    func testSubmitAssignmentSendsBackSupportedSubmissionTypes() {
        let assignment = Assignment.make(["id": "1"])
        assignment.submissionTypes = [.online_upload, .online_url]

        presenter.viewIsReady()
        let viewController = UIViewController()
        presenter.submitAssignment(from: viewController)

        XCTAssertEqual(resultingSubmissionTypes, [.online_upload, .online_url])
    }

    func testSubmitDiscussion() {
        let url = URL(string: "/courses/1/discussions/2")!
        let a = Assignment.make(["id": "1"])
        presenter.submit(.discussion_topic, from: UIViewController())
        XCTAssertEqual(router.calls.count, 0)
        a.discussionTopic = DiscussionTopic.make([ "htmlUrl": url ])
        presenter.submit(.discussion_topic, from: UIViewController())
        XCTAssert(router.lastRoutedTo(url))
    }

    func testExternalToolSubmission() {
        Assignment.make(["id": "1", "courseID": "1"])
        let request = GetSessionlessLaunchURLRequest(context: ContextModel(.course, id: "1"), id: nil, url: nil, assignmentID: "1", moduleItemID: nil, launchType: .assessment)
        api.mock(request, value: APIGetSessionlessLaunchResponse(id: "", name: "", url: URL(string: "https://instructure.com")!))
        let openedSFSafariViewController = XCTestExpectation(description: "opened")
        presenter.submit(.external_tool, from: UIViewController()) {
            openedSFSafariViewController.fulfill()
        }
        wait(for: [openedSFSafariViewController], timeout: 1)
        XCTAssert(router.viewControllerCalls[0].0 is SFSafariViewController)
    }

    func testAddOnlineUploadFile() {
        let url = URL(fileURLWithPath: "/file.txt")
        presenter.addOnlineUpload(file: url)
        XCTAssertEqual(presenter.files.count, 1)
    }

    func testCancelOnlineUpload() {
        let url = URL(fileURLWithPath: "/file.txt")
        presenter.addOnlineUpload(file: url)
        XCTAssertEqual(presenter.files.count, 1)
        presenter.cancelOnlineUpload()
        XCTAssertEqual(presenter.files.count, 0)
        XCTAssertEqual(fileUploader.cancels.count, 1)
    }

    func testSubmitOnlineUpload() {
        let url = URL(fileURLWithPath: "/file.txt")
        presenter.addOnlineUpload(file: url)
        presenter.submitOnlineUpload()
        XCTAssertEqual(fileUploader.uploads.count, 1)
    }

    func testCancelMediaRecording() {
        presenter.userID = "1"
        let url = URL(string: "data:video/x-mp4,abcde")!
        let request = GetMediaServiceRequest()
        MockURLSession.mock(request, error: NSError.internalError())
        presenter.submit(mediaRecording: url, type: .video) { _ in }
        presenter.cancelMediaRecording()
        let task = MockURLSession.mockDataTask(request)
        XCTAssertNotNil(task)
        XCTAssert(task?.canceled == true)
    }

    func testSubmitMediaRecording() {
        presenter.userID = "1"
        let url = URL(string: "data:video/x-mp4,abcde")!
        MockURLSession.mock(GetMediaServiceRequest(), value: APIMediaService(domain: "u.edu"))
        MockURLSession.mock(PostMediaSessionRequest(), value: APIMediaSession(ks: "k"))
        MockURLSession.mock(PostMediaUploadTokenRequest(body: .init(ks: "k")), value: APIMediaIDWrapper(id: "t"))
        MockURLSession.mock(PostMediaUploadRequest(fileURL: url, type: .video, ks: "k", token: "t"))
        MockURLSession.mock(PostMediaIDRequest(ks: "k", token: "t", type: .video), value: APIMediaIDWrapper(id: "2"))
        let expectation = self.expectation(description: "upload media succeeded")
        presenter.submit(mediaRecording: url, type: .video) { error in
            XCTAssertNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
    }

    func testSubmitMediaRecordingError() {
        presenter.userID = "1"
        let url = URL(string: "data:video/x-mp4,abcde")!
        MockURLSession.mock(GetMediaServiceRequest(), error: NSError.internalError())
        let expectation = self.expectation(description: "upload media failed")
        presenter.submit(mediaRecording: url, type: .video) { error in
            XCTAssertNotNil(error)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
    }
}

extension AssignmentDetailsPresenterTests: AssignmentDetailsViewProtocol {
    func showSubmitAssignmentButton(title: String?) {
        resultingButtonTitle = title
    }

    func chooseSubmissionType(_ types: [SubmissionType]) {
        resultingSubmissionTypes = types
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

    func present(filePicker: FilePickerViewController) {
        self.filePicker = filePicker
    }

    func chooseMediaRecordingType() {
        didChooseMediaRecordingType = true
    }
}
