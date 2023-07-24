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
import Core
import TestsFoundation
import XCTest

public class QuizzesHelper: BaseHelper {
    // MARK: Test Data
    struct TestData {
        struct Question1 {
            static let type = DSQuestionType.multipleChoiceQuestion
            static let text = "What is the meaning of life?"
            struct Answers {
                static let correct = "42"
                static let wrongs = ["11", "13", "17"]
            }
        }
        struct Question2 {
            static let type = DSQuestionType.multipleChoiceQuestion
            static let text = "How many choices are there for this question?"
            struct Answers {
                static let correct = "4"
                static let wrongs = ["19", "23", "29"]
            }
        }
    }

    // MARK: UI Elements
    struct Details {
        public static var nameLabel: Element { app.find(id: "AssignmentDetails.name") }
        public static var pointsLabel: Element { app.find(id: "AssignmentDetails.points") }
        public static var statusLabel: Element { app.find(id: "AssignmentDetails.status") }
        public static var takeQuizButton: Element { return app.find(id: "QuizDetails.takeButton") }
        public static var dueLabel: Element {
            return app.find(id: "AssignmentDetails.dueSection").rawElement.find(id: "dueDateLabel")
        }
        public static var questionsLabel: Element {
            return app.find(id: "AssignmentDetails.quizSection").rawElement.find(id: "questionsValueLabel")
        }
        public static var timeLimitLabel: Element {
            return app.find(id: "AssignmentDetails.quizSection").rawElement.find(id: "timeLimitValueLabel")
        }
        public static var attemptsLabel: Element {
            return app.find(id: "AssignmentDetails.quizSection").rawElement.find(id: "attemptsValueLabel")
        }

        public static func descriptionLabel(quiz: DSQuiz) -> Element {
            return app.find(label: quiz.description, type: .staticText)
        }

        public static func navBar(course: DSCourse) -> Element {
            return app.find(id: "Quiz Details, \(course.name)")
        }

        struct TakeQuiz {
            public static var navBar: Element { app.find(id: "Take Quiz") }
            public static var exitButton: Element { app.find(label: "Exit", type: .button) }
            public static var takeTheQuizButton: Element { app.find(label: "Take the Quiz", type: .link) }
            public static var submitQuizButton: Element { app.find(label: "Submit Quiz", type: .button) }

            public static func answerFirstQuestion() {
                // Correct answer to first question
                exitButton.waitToExist()
                let firstQuestionAnswer = app.find(label: TestData.Question1.Answers.correct, type: .staticText)
                firstQuestionAnswer.swipeUntilVisible()
                firstQuestionAnswer.tap()
            }

            public static func answerSecondQuestion() {
                // Correct answer to second question
                exitButton.waitToExist()
                let secondQuestionAnswer = app.find(label: TestData.Question2.Answers.correct, type: .staticText)
                secondQuestionAnswer.swipeUntilVisible()
                secondQuestionAnswer.tap()
            }
        }
    }

    public static func dueDateLabel(cell: Element) -> Element {
        return cell.rawElement.find(id: "dateLabel", type: .staticText)
    }

    public static func pointsLabel(cell: Element) -> Element {
        return cell.rawElement.find(id: "pointsLabel", type: .staticText)
    }

    public static func questionsLabel(cell: Element) -> Element {
        return cell.rawElement.find(id: "questionsLabel", type: .staticText)
    }

    public static func titleLabel(cell: Element) -> Element {
        return cell.rawElement.find(id: "titleLabel", type: .staticText)
    }

    public static func cell(index: Int) -> Element {
        return app.find(id: "QuizListCell.0.\(index)")
    }

    public static func navBar(course: DSCourse) -> Element {
        return app.find(id: "Quizzes, \(course.name)")
    }

    public static func navigateToQuizzes(course: DSCourse) {
        DashboardHelper.courseCard(course: course).tap()
        CourseDetailsHelper.cell(type: .quizzes).swipeUntilVisible()
        CourseDetailsHelper.cell(type: .quizzes).tap()
    }

    // MARK: DataSeeding
    @discardableResult
    public static func createQuiz(course: DSCourse,
                                  title: String,
                                  description: String,
                                  quiz_type: DSQuizType,
                                  points_possible: Float = 10.0,
                                  published: Bool = false) -> DSQuiz {
        let quizBody = CreateDSQuizRequest.RequestedDSQuiz(title: title, description: description, quiz_type: quiz_type, points_possible: points_possible, published: published)
        return seeder.createQuiz(courseId: course.id, quizBody: quizBody)
    }

    @discardableResult
    public static func createTestQuizWith2Questions(course: DSCourse) -> DSQuiz {
        let quiz = createQuiz(course: course,
                              title: "Test Quiz",
                              description: "Description of Test Quiz",
                              quiz_type: .assignment,
                              published: false)
        createTestQuizQuestions(course: course, quiz: quiz)
        return updateQuiz(course: course, quiz: quiz, published: true)
    }

    @discardableResult
    public static func createQuizQuestion(course: DSCourse,
                                          quiz: DSQuiz,
                                          type: DSQuestionType,
                                          text: String,
                                          points_possible: Float = 5.0,
                                          answers: [DSAnswer]) -> DSQuizQuestion {
        let quizQuestionBody = CreateDSQuizQuestionRequest.RequestedDSQuizQuestion(question_text: text, question_type: type, points_possible: points_possible, answers: answers)
        return seeder.createQuizQuestion(courseId: course.id, quizId: quiz.id, quizQuestionBody: quizQuestionBody)
    }

    @discardableResult
    public static func createTestQuizQuestions(course: DSCourse, quiz: DSQuiz) -> [DSQuizQuestion] {
        var questions = [DSQuizQuestion]()
        var answers1 = [DSAnswer]()
        answers1.append(DSAnswer(text: TestData.Question1.Answers.wrongs[0], weight: 0))
        answers1.append(DSAnswer(text: TestData.Question1.Answers.wrongs[1], weight: 0))
        answers1.append(DSAnswer(text: TestData.Question1.Answers.wrongs[2], weight: 0))
        answers1.append(DSAnswer(text: TestData.Question1.Answers.correct, weight: 100))

        questions.append(createQuizQuestion(course: course,
                                            quiz: quiz,
                                            type: TestData.Question1.type,
                                            text: TestData.Question1.text,
                                            points_possible: 5.0,
                                            answers: answers1))

        var answers2 = [DSAnswer]()
        answers2.append(DSAnswer(text: TestData.Question2.Answers.wrongs[0], weight: 0))
        answers2.append(DSAnswer(text: TestData.Question2.Answers.wrongs[1], weight: 0))
        answers2.append(DSAnswer(text: TestData.Question2.Answers.wrongs[2], weight: 0))
        answers2.append(DSAnswer(text: TestData.Question2.Answers.correct, weight: 100))

        questions.append(createQuizQuestion(course: course,
                                            quiz: quiz,
                                            type: TestData.Question2.type,
                                            text: TestData.Question2.text,
                                            points_possible: 5.0,
                                            answers: answers2))

        return questions
    }

    @discardableResult
    public static func updateQuiz(course: DSCourse, quiz: DSQuiz, published: Bool = true) -> DSQuiz {
        return seeder.updateQuiz(courseId: course.id, quizId: quiz.id, published: published)
    }
}
