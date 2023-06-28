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
    @discardableResult
    public static func createQuiz(course: DSCourse, title: String, description: String, quiz_type: DSQuizType, published: Bool = true) -> DSQuiz {
        let quizBody = CreateDSQuizRequest.RequestedDSQuiz(title: title, description: description, quiz_type: quiz_type, published: published)
        return try! seeder.createQuiz(courseId: course.id, quizBody: quizBody)
    }

    @discardableResult
    public static func createQuizQuestion(course: DSCourse, quiz: DSQuiz, name: String, type: DSQuestionType, text: String, answers: [DSAnswer]) -> DSQuizQuestion {
        let quizQuestionBody = CreateDSQuizQuestionRequest.RequestedDSQuizQuestion(question_text: text, question_type: type, answers: answers)
        return try! seeder.createQuizQuestion(courseId: course.id, quizId: quiz.id, quizQuestionBody: quizQuestionBody)
    }

    @discardableResult
    public static func createTestQuizQuestion(course: DSCourse, quiz: DSQuiz) -> DSQuizQuestion {
        let name = "Test Quiz Question"
        let type = DSQuestionType.multipleChoiceQuestion
        let text = "What is the meaning of life?"

        var answers = [DSAnswer]()
        answers.append(DSAnswer(answer_text: "1", answer_weight: 0, answer_precision: 10))
        answers.append(DSAnswer(answer_text: "2", answer_weight: 0, answer_precision: 10))
        answers.append(DSAnswer(answer_text: "3", answer_weight: 0, answer_precision: 10))
        answers.append(DSAnswer(answer_text: "42", answer_weight: 100, answer_precision: 10))

        return createQuizQuestion(course: course, quiz: quiz, name: name, type: type, text: text, answers: answers)
    }
}
