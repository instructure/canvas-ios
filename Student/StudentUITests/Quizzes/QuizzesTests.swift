//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

@testable import TestsFoundation
@testable import Core
@testable import CoreUITests

class QuizzesTests: StudentUITestCase {
    func mockQuestions(forSubmission submission: APIQuizSubmission, answered: Bool) {
        mockEncodableRequest("quiz_submissions/\(submission.id)/questions", value: [
            "quiz_submission_questions": [
                APIQuizQuestion.make(
                    id: "1",
                    quiz_id: submission.quiz_id.value,
                    position: 1,
                    question_name: "Question 1",
                    question_type: .multiple_choice_question,
                    question_text: "q1",
                    answers: [
                        .make(id: "1", text: "A"),
                        .make(id: "2", text: "B"),
                        .make(id: "3", text: "C"),
                    ],
                    answer: answered ? .double(2) : nil
                ),
                APIQuizQuestion.make(
                    id: "2",
                    quiz_id: submission.quiz_id.value,
                    position: 2,
                    question_name: "Question 2",
                    question_type: .true_false_question,
                    question_text: "q2",
                    answers: [
                        .make(id: "1", text: "True"),
                        .make(id: "2", text: "False"),
                    ]
                ),
                APIQuizQuestion.make(
                    id: "3",
                    quiz_id: submission.quiz_id.value,
                    position: 3,
                    question_name: "Question 3",
                    question_type: .numerical_question,
                    question_text: "q3",
                    answer: answered ? .double(4.2) : nil
                ),
            ],
        ])
    }

    func testTakeQuiz() {
        mockBaseRequests()

        let quiz = APIQuiz.make(
            question_count: 3,
            question_types: [
                .multiple_choice_question,
                .true_false_question,
                .numerical_question,
            ],
            quiz_type: .assignment
        )

        mockData(GetQuizRequest(courseID: "1", quizID: quiz.id.value), value: quiz)
        let assignment = mock(assignment: APIAssignment.make(
            quiz_id: quiz.id,
            name: "A quiz",
            submission_types: [.online_quiz ]
        ))
        mockData(GetQuizSubmissionRequest(courseID: "1", quizID: quiz.id.value),
                 value: .init(quiz_submissions: []))
        show("courses/1/assignments/\(assignment.id)")

        let submission = APIQuizSubmission.make(quiz_id: quiz.id, workflow_state: .untaken)

        mockData(PostQuizSubmissionRequest(courseID: "1", quizID: quiz.id.value, body: nil),
                 value: .init(quiz_submissions: [submission]))

        mockEncodableRequest("courses/1/quizzes/\(quiz.id)/submissions/\(submission.id)/events", value: nil as String?)

        mockQuestions(forSubmission: submission, answered: false)
        XCTAssertEqual(AssignmentDetails.submitAssignmentButton.label(), "Take Quiz")
        AssignmentDetails.submitAssignmentButton.tap()

        XCTAssertFalse(app.find(label: "q1").isOffscreen())
        XCTAssertTrue(app.find(label: "q3").isOffscreen())

        app.find(label: "A").tap()
        app.find(label: "C").tap()

        app.find(label: "Show Question List").tap()
        app.find(label: "Question 2").tap()
        XCTAssertFalse(app.find(label: "q3").isOffscreen())

        app.find(label: "True").tap()

        app.find(label: "Submit").tap()
        handleAlert(withTexts: [
            "1 questions not answered",
            "Are you sure you want to submit your answers?",
        ], byPressingButton: "Cancel")

        app.find(id: "ShortAnswerCell.textField").typeText("42")
        app.find(label: "Submit").tap()

        mockData(
            PostQuizSubmissionCompleteRequest(
                courseID: "1",
                quizID: quiz.id.value,
                quizSubmissionID: submission.id.value,
                body: nil),
            value: .init(quiz_submissions: [ submission ]))

        handleAlert(withTexts: [
            "Are you sure you want to submit your answers?",
        ], byPressingButton: "Submit")

        app.find(label: "Quiz Submitted").waitToExist()
        app.find(label: "Done").tap().waitToVanish()
    }

    func testResumeQuiz() {
        mockBaseRequests()

        let quiz = APIQuiz.make(
            question_count: 3,
            question_types: [
                .multiple_choice_question,
                .true_false_question,
                .numerical_question,
            ],
            quiz_type: .assignment
        )
        let quizSubmission = APIQuizSubmission.make(
            id: 7,
            quiz_id: quiz.id,
            started_at: Date()
        )

        mockData(GetQuizRequest(courseID: "1", quizID: quiz.id.value), value: quiz)
        let assignment = mock(assignment: APIAssignment.make(
            quiz_id: quiz.id,
            name: "A quiz",
            submission_types: [.online_quiz ]
        ))

        mockData(GetQuizSubmissionRequest(courseID: "1", quizID: quiz.id.value),
                 value: .init(quiz_submissions: [ quizSubmission ]))
        show("courses/1/assignments/\(assignment.id)")
        mockData(PostQuizSubmissionRequest(courseID: "1", quizID: quiz.id.value, body: nil),
                 value: .init(quiz_submissions: [ quizSubmission ]))
        mockEncodableRequest("courses/1/quizzes/\(quiz.id)/submissions/\(quizSubmission.id)/events", value: nil as String?)

        mockQuestions(forSubmission: quizSubmission, answered: true)
        XCTAssertEqual(AssignmentDetails.submitAssignmentButton.label(), "Resume Quiz")

        AssignmentDetails.submitAssignmentButton.tap()
        XCTAssertEqual(Double(app.find(id: "ShortAnswerCell.textField").value() ?? "-8"), 4.2)
        app.find(label: "Submit").tap()
        handleAlert(withTexts: [
            "1 questions not answered",
            "Are you sure you want to submit your answers?",
        ], byPressingButton: "Cancel")
        app.find(label: "True").tap()
        app.find(label: "Submit").tap()
        mockData(
            PostQuizSubmissionCompleteRequest(
                courseID: "1",
                quizID: quiz.id.value,
                quizSubmissionID: quizSubmission.id.value,
                body: nil),
            value: .init(quiz_submissions: [ quizSubmission ]))
        handleAlert(withTexts: [
            "Are you sure you want to submit your answers?",
        ], byPressingButton: "Submit")

        app.find(label: "Quiz Submitted").waitToExist()
        app.find(label: "Done").tap().waitToVanish()
    }

    func testQuizTimeout() {
        mockBaseRequests()
        let quiz = APIQuiz.make(
            due_at: Date(),
            question_count: 3,
            question_types: [
                .multiple_choice_question,
                .true_false_question,
                .numerical_question,
            ],
            quiz_type: .survey,
            time_limit: 10
        )

        let submission = APIQuizSubmission.make()

        mockData(GetQuizRequest(courseID: "1", quizID: quiz.id.value), value: quiz)
        mockData(GetQuizSubmissionRequest(courseID: "1", quizID: quiz.id.value),
                 value: .init(quiz_submissions: []))
        mockData(GetAllQuizSubmissionsRequest(courseID: "1", quizID: quiz.id.value),
                 value: .init(quiz_submissions: [], submissions: nil))

        show("courses/1/quizzes/\(quiz.id)")
        app.swipeLeft()

        let quizTime = 10

        mockData(PostQuizSubmissionRequest(courseID: "1", quizID: quiz.id.value, body: nil),
                 value: .init(quiz_submissions: [ submission ]))
        mockEncodableRequest("courses/1/quizzes/123/submissions/1/events", value: nil as String?)
        mockEncodableRequest("courses/1/quizzes/123/submissions/1/time", value: ["time_left": quizTime])
        let completed = XCTestExpectation()
        mockQuestions(forSubmission: submission, answered: false)
        mockRequest("courses/1/quizzes/123/submissions/1/complete") { _ in
            completed.fulfill()
            return MockHTTPResponse(value: PostQuizSubmissionRequest.Response.init(quiz_submissions: [submission]))!
        }
        app.find(label: "Take Quiz").tap()
        waitUntil { !Quiz.timer.label().isEmpty }
        XCTAssertLessThanOrEqual(Int(Quiz.timer.label()) ?? Int.max, quizTime)

        wait(for: [completed], timeout: 30)
    }
}
