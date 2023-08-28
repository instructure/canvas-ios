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

public class QuizzesHelper: BaseHelper {
    // MARK: Test Data
    public struct TestData {
        public struct Question1 {
            static let type = DSQuestionType.multipleChoiceQuestion
            static let text = "What is the meaning of life?"
            public struct Answers {
                static let correct = "42"
                static let wrongs = ["11", "13", "17"]
            }
        }
        public struct Question2 {
            static let type = DSQuestionType.multipleChoiceQuestion
            static let text = "How many choices are there for this question?"
            public struct Answers {
                static let correct = "4"
                static let wrongs = ["19", "23", "29"]
            }
        }
    }

    // MARK: UI Elements
    public struct Details {
        public static var nameLabel: XCUIElement { app.find(id: "AssignmentDetails.name") }
        public static var pointsLabel: XCUIElement { app.find(id: "AssignmentDetails.points") }
        public static var statusLabel: XCUIElement { app.find(id: "AssignmentDetails.status") }
        public static var takeQuizButton: XCUIElement { app.find(id: "QuizDetails.takeButton") }
        public static var submitButton: XCUIElement { app.find(label: "Submit") }
        public static var previewQuiz: XCUIElement { app.find(label: "Preview Quiz") }
        public static var launchExternalToolButton: XCUIElement { app.find(label: "Launch External Tool", type: .button) }
        public static var dueLabel: XCUIElement {
            app.find(id: "AssignmentDetails.dueSection").find(id: "dueDateLabel")
        }
        public static var questionsLabel: XCUIElement {
            app.find(id: "AssignmentDetails.quizSection").find(id: "questionsValueLabel")
        }
        public static var timeLimitLabel: XCUIElement {
            app.find(id: "AssignmentDetails.quizSection").find(id: "timeLimitValueLabel")
        }
        public static var attemptsLabel: XCUIElement {
            app.find(id: "AssignmentDetails.quizSection").find(id: "attemptsValueLabel")
        }

        public static func descriptionLabel(quiz: DSQuiz) -> XCUIElement {
            return app.find(label: quiz.description, type: .staticText)
        }

        public static func navBar(course: DSCourse) -> XCUIElement {
            return app.find(id: "Quiz Details, \(course.name)")
        }

        public struct TakeQuiz {
            public static var navBar: XCUIElement { app.find(id: "Take Quiz") }
            public static var exitButton: XCUIElement { app.find(label: "Exit", type: .button) }
            public static var takeTheQuizButton: XCUIElement { app.find(label: "Take the Quiz", type: .link) }
            public static var submitQuizButton: XCUIElement { app.find(label: "Submit Quiz", type: .button) }

            public static func answerFirstQuestion() {
                // Correct answer to first question
                exitButton.waitUntil(.visible)
                let firstQuestionAnswer = app.find(label: TestData.Question1.Answers.correct, type: .staticText)
                firstQuestionAnswer.actionUntilElementCondition(action: .swipeUp(), condition: .visible)
                firstQuestionAnswer.hit()
            }

            public static func answerSecondQuestion() {
                // Correct answer to second question
                exitButton.waitUntil(.visible)
                let secondQuestionAnswer = app.find(label: TestData.Question2.Answers.correct, type: .staticText)
                secondQuestionAnswer.actionUntilElementCondition(action: .swipeUp(), condition: .visible)
                secondQuestionAnswer.hit()
            }
        }
    }

    public static func dueDateLabel(cell: XCUIElement) -> XCUIElement {
        return cell.find(id: "dateLabel", type: .staticText)
    }

    public static func pointsLabel(cell: XCUIElement) -> XCUIElement {
        return cell.find(id: "pointsLabel", type: .staticText)
    }

    public static func questionsLabel(cell: XCUIElement) -> XCUIElement {
        return cell.find(id: "questionsLabel", type: .staticText)
    }

    public static func titleLabel(cell: XCUIElement) -> XCUIElement {
        return cell.find(id: "titleLabel", type: .staticText)
    }

    public static func cell(index: Int) -> XCUIElement {
        return app.find(id: "QuizListCell.0.\(index)")
    }

    public static func navBar(course: DSCourse) -> XCUIElement {
        return app.find(id: "Quizzes, \(course.name)")
    }

    public static func navigateToQuizzes(course: DSCourse) {
        DashboardHelper.courseCard(course: course).hit()
        CourseDetailsHelper.titleLabel.waitUntil(.visible)
        let quizzesCell = CourseDetailsHelper.cell(type: .quizzes)
        quizzesCell.waitUntil(.visible)
        quizzesCell.actionUntilElementCondition(action: .swipeUp(), condition: .hittable)
        quizzesCell.hit()
    }

    // MARK: DataSeeding
    @discardableResult
    public static func createQuiz(course: DSCourse,
                                  title: String,
                                  description: String,
                                  quiz_type: DSQuizType,
                                  points_possible: Float = 10.0,
                                  published: Bool = false,
                                  due_at: Date? = nil) -> DSQuiz {
        let quizBody = CreateDSQuizRequest.RequestedDSQuiz(title: title, description: description, quiz_type: quiz_type, points_possible: points_possible, published: published, due_at: due_at)
        return seeder.createQuiz(courseId: course.id, quizBody: quizBody)
    }

    @discardableResult
    public static func createTestQuizWith2Questions(course: DSCourse, due_at: Date? = nil) -> DSQuiz {
        let quiz = createQuiz(course: course,
                              title: "Test Quiz",
                              description: "Description of Test Quiz",
                              quiz_type: .assignment,
                              published: false,
                              due_at: due_at)
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
