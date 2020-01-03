//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
@testable import TestsFoundation
@testable import CoreUITests
@testable import Core

class QuizTests: CoreUITestCase {
    func testQuizQuestionsOpenInNativeView() {
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.quizzes.tap()

        app.find(labelContaining: "Quiz One").tap()
        Quiz.resumeButton.tap()

        Quiz.text(string: "This is question A").waitToExist()
        Quiz.text(string: "True").waitToExist()

        Quiz.text(string: "This is question B").waitToExist()
        Quiz.text(string: "Answer B.1").waitToExist()

        app.swipeUp()

        Quiz.text(string: "This is question C").waitToExist()
        Quiz.text(string: "Answer 1.A").waitToExist()

        Quiz.text(string: "This is question D").waitToExist()
        XCTAssertEqual(app.textFields.firstElement.value(), "42.000000")
    }

    func testQuizQuestionsOpenInWebView() {
        Dashboard.courseCard(id: "263").tap()
        CourseNavigation.quizzes.tap()

        app.find(labelContaining: "Web Quiz").tap()
        Quiz.resumeButton.tap()
        app.find(label: "This quiz is for testing web view question types.").waitToExist()
    }

    func testQuizzesShowEmptyState() {
        Dashboard.courseCard(id: "262").tap()
        CourseNavigation.announcements.waitToExist()
        CourseNavigation.quizzes.waitToVanish()
    }
}

class MockedQuizTests: StudentUITestCase {
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
        let assignment = mock(assignment: APIAssignment.make(
            quiz_id: quiz.id,
            name: "A quiz",
            submission_types: [.online_quiz ]
        ))
        mockData(GetQuizRequest(courseID: "1", quizID: quiz.id.value), value: quiz)
        mockData(GetQuizSubmissionRequest(courseID: "1", quizID: quiz.id.value),
                 value: .init(quiz_submissions: []))
        show("courses/1/assignments/\(assignment.id)")

        let submission = APIQuizSubmission.make(quiz_id: quiz.id, workflow_state: .untaken)

        mockData(PostQuizSubmissionRequest(courseID: "1", quizID: quiz.id.value, body: nil),
                 value: .init(quiz_submissions: [submission]))

        mockEncodableRequest("courses/1/quizzes/\(quiz.id)/submissions/\(submission.id)/events", value: "")
        mockEncodableRequest("quiz_submissions/1/questions", value: [
            "quiz_submission_questions": [
                APIQuizQuestion.make(
                    id: "1",
                    quiz_id: quiz.id.value,
                    position: 1,
                    question_name: "Question 1",
                    question_type: .multiple_choice_question,
                    question_text: "q1",
                    answers: [
                        .make(id: "1", text: "A"),
                        .make(id: "2", text: "B"),
                        .make(id: "3", text: "C"),
                    ]
                ),
                APIQuizQuestion.make(
                    id: "2",
                    quiz_id: quiz.id.value,
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
                    quiz_id: quiz.id.value,
                    position: 3,
                    question_name: "Question 3",
                    question_type: .numerical_question,
                    question_text: "q3"
                ),
            ],
        ])

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
}
