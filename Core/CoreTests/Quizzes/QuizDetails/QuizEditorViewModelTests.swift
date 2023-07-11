//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import Foundation

import XCTest
@testable import Core

class QuizEditorViewModelTests: CoreTestCase {
    let courseID = "1"
    let quizID = "2"
    let assignmentID = "3"
    let assignmentGroupID = "15"

    func testAttributes() {
        let apiQuiz = APIQuiz.make(
            access_code: "TrustNo1",
            allowed_attempts: 10,
            assignment_id: ID(assignmentID),
            cant_go_back: true,
            description: "test description",
            has_access_code: true,
            id: ID(quizID),
            one_question_at_a_time: true,
            points_possible: 5,
            published: true,
            quiz_type: .graded_survey,
            scoring_policy: .keep_highest,
            shuffle_answers: true,
            time_limit: 10,
            title: "test quiz",
            unpublishable: true
        )
        api.mock(GetQuizRequest(courseID: courseID, quizID: quizID), value: apiQuiz)
        api.mock(GetAssignment(courseID: courseID, assignmentID: assignmentID, include: GetAssignmentRequest.GetAssignmentInclude.allCases), value: .make())
        api.mock(GetAssignmentGroups(courseID: courseID), value: [.make()])

        let testee = QuizEditorViewModel(courseID: courseID, quizID: quizID)
        drainMainQueue()

        XCTAssertEqual(testee.title, "test quiz")
        XCTAssertEqual(testee.description, "test description")
        XCTAssertEqual(testee.quizType, .graded_survey)
        XCTAssertTrue(testee.published)
        XCTAssertTrue(testee.shuffleAnswers)
        XCTAssertTrue(testee.timeLimit)
        XCTAssertEqual(testee.lengthInMinutes, 10)
        XCTAssertTrue(testee.allowMultipleAttempts)
        XCTAssertEqual(testee.scoreToKeep, .keep_highest)
        XCTAssertEqual(testee.allowedAttempts, 10)
        XCTAssertTrue(testee.oneQuestionAtaTime)
        XCTAssertTrue(testee.lockQuestionAfterViewing)
        XCTAssertTrue(testee.requireAccessCode)
        XCTAssertEqual(testee.accessCode, "TrustNo1")
        XCTAssertTrue(testee.shouldShowPublishedToggle)
    }

    func testFetchQuizError() {
        api.mock(GetQuizRequest(courseID: courseID, quizID: quizID), value: nil, error: NSError.internalError())

        let testee = QuizEditorViewModel(courseID: courseID, quizID: quizID)
        drainMainQueue()
        XCTAssertEqual(testee.state, .error("Internal Error"))
    }

    func testFetchAssignmentError() {
        api.mock(GetQuizRequest(courseID: courseID, quizID: quizID), value: .make(assignment_id: ID(assignmentID), id: ID(quizID)))
        api.mock(GetAssignment(courseID: courseID, assignmentID: assignmentID, include: GetAssignmentRequest.GetAssignmentInclude.allCases), value: nil, error: NSError.internalError())
        let testee = QuizEditorViewModel(courseID: courseID, quizID: quizID)
        drainMainQueue()
        XCTAssertEqual(testee.state, .error("Internal Error"))
    }

    func testFetchAssignmentGroupError() {
        api.mock(GetAssignmentGroups(courseID: courseID), value: nil, error: NSError.internalError())
        let testee = QuizEditorViewModel(courseID: courseID, quizID: quizID)
        drainMainQueue()
        XCTAssertEqual(testee.state, .error("Internal Error"))
    }

    func testValidate() {
        mockData()
        let testee = QuizEditorViewModel(courseID: courseID, quizID: quizID)
        drainMainQueue()
        XCTAssertTrue(testee.validate())
        testee.title = ""
        XCTAssertFalse(testee.validate())
        testee.title = " "
        XCTAssertFalse(testee.validate())
        testee.title = "Title"
        testee.accessCode = ""
        XCTAssertFalse(testee.validate())
        testee.accessCode = " "
        XCTAssertFalse(testee.validate())
        testee.requireAccessCode = false
        XCTAssertTrue(testee.validate())
    }

    func testDoneTapped() {
        mockData()
        let expectedBody = PutQuizRequest.Body(quiz: APIQuizParameters(
            access_code: "NewAccesCode",
            allowed_attempts: 99,
            assignment_group_id: nil,
            cant_go_back: true,
            description: "New Description",
            one_question_at_a_time: true,
            published: false,
            quiz_type: .assignment,
            scoring_policy: .keep_average,
            shuffle_answers: true,
            time_limit: 100.0,
            title: "New Title"
        ))
        let apiExpectation = expectation(description: "Quiz Updated")
        let testee = QuizEditorViewModel(courseID: courseID, quizID: quizID)
        drainMainQueue()

        testee.accessCode = "NewAccesCode"
        testee.allowedAttempts = 99
        testee.oneQuestionAtaTime = true
        testee.lockQuestionAfterViewing = true
        testee.description = "New Description"
        testee.oneQuestionAtaTime = true
        testee.published = false
        testee.quizType = .assignment
        testee.allowMultipleAttempts = true
        testee.scoreToKeep = .keep_average
        testee.shuffleAnswers = true
        testee.timeLimit = true
        testee.lengthInMinutes = 100
        testee.title = "New Title"

        let request = PutQuizRequest(courseID: courseID, quizID: quizID, body: nil)
        api.mock(request) { urlRequest in
            if let httpBody = urlRequest.httpBody {
                let body = try? JSONDecoder().decode(PutQuizRequest.Body.self, from: httpBody)
                XCTAssertEqual(expectedBody, body)
                apiExpectation.fulfill()
            }
            return (nil, nil, nil)
        }

        testee.doneTapped(router: router, viewController: WeakViewController(UIViewController()))

        waitForExpectations(timeout: 1)
    }

    func testQuizUpdateError() {
        mockData()
        let testee = QuizEditorViewModel(courseID: courseID, quizID: quizID)
        let request = PutQuizRequest(courseID: courseID, quizID: quizID, body: nil)
        api.mock(request, value: nil, error: NSError.internalError())
        drainMainQueue()

        let expectation = self.expectation(description: "error received")

        let errorListener = testee.showErrorPopup.sink { alert in
            XCTAssertEqual(alert.title, "Internal Error")
            expectation.fulfill()
        }

        testee.doneTapped(router: router, viewController: WeakViewController(UIViewController()))

        waitForExpectations(timeout: 1)
        errorListener.cancel()
    }

    func testSaveAssignment() {
        mockData()
        let expectedBody = PutAssignmentRequest.Body(assignment: APIAssignmentParameters(
            assignment_overrides: [],
            description: "New Description",
            due_at: nil,
            grading_type: .points,
            lock_at: nil,
            name: "New Name",
            only_visible_to_overrides: true,
            points_possible: 10,
            published: true,
            unlock_at: nil
        ))
        let apiExpectation = expectation(description: "Assignment Updated")

        let testee = QuizEditorViewModel(courseID: courseID, quizID: quizID)
        drainMainQueue()
        testee.description = "New Description"
        testee.published = true
        testee.title = "New Name"

        let request = PutAssignmentRequest(courseID: courseID, assignmentID: assignmentID, body: nil)
        api.mock(request) { urlRequest in
            if let httpBody = urlRequest.httpBody {
                let body = try? JSONDecoder().decode(PutAssignmentRequest.Body.self, from: httpBody)
                XCTAssertEqual(expectedBody, body)
                apiExpectation.fulfill()
            }
            return (APIAssignment.make(), nil, nil)
        }
        testee.assignment = Assignment.make()
        testee.saveAssignment(router: router, viewController: WeakViewController(UIViewController()))
        waitForExpectations(timeout: 1)
    }

    func testAssignmentUpdateError() {
        mockData()
        let testee = QuizEditorViewModel(courseID: courseID, quizID: quizID)
        let request = PutAssignmentRequest(courseID: courseID, assignmentID: assignmentID, body: nil)
        api.mock(request, value: nil, error: NSError.internalError())
        testee.assignment = Assignment.make()

        XCTAssertNil(router.dismissed)

        testee.saveAssignment(router: router, viewController: WeakViewController(UIViewController()))

        XCTAssertNotNil(router.dismissed)
    }

    func testQuizTypeTapped() {
        let testee = QuizEditorViewModel(courseID: courseID, quizID: quizID)
        testee.quizTypeTapped(router: router, viewController: WeakViewController(UIViewController()))

        XCTAssertEqual((router.lastViewController as? ItemPickerViewController)?.title, "Quiz Type")

        router.viewControllerCalls.removeAll()
    }

    func testAssignmentGroupTapped() {
        let testee = QuizEditorViewModel(courseID: courseID, quizID: quizID)
        testee.assignmentGroup = .make()
        testee.assignmentGroupTapped(router: router, viewController: WeakViewController(UIViewController()))

        XCTAssertEqual((router.lastViewController as? ItemPickerViewController)?.title, "Assignment Group")

        router.viewControllerCalls.removeAll()
    }

    func testScoreToKeepTapped() {
        let testee = QuizEditorViewModel(courseID: courseID, quizID: quizID)
        testee.scoreToKeepTapped(router: router, viewController: WeakViewController(UIViewController()))

        XCTAssertEqual((router.lastViewController as? ItemPickerViewController)?.title, "Quiz Score to Keep")

        router.viewControllerCalls.removeAll()
    }

    private func mockData() {
        let apiQuiz = APIQuiz.make(
            access_code: "TrustNo1",
            assignment_id: "3",
            description: "test description",
            has_access_code: true,
            id: ID(quizID),
            points_possible: 5,
            published: true,
            time_limit: 10,
            title: "test quiz"
        )
        api.mock(GetQuizRequest(courseID: courseID, quizID: quizID), value: apiQuiz)
        api.mock(GetAssignment(courseID: courseID, assignmentID: assignmentID, include: GetAssignmentRequest.GetAssignmentInclude.allCases), value: .make())
        api.mock(GetAssignmentGroups(courseID: courseID), value: [.make()])
    }
}
