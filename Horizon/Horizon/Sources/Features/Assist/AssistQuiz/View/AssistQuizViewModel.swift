//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct AssistQuizModel {
    // MARK: - Properties

    let id: UUID
    let question: String
    let options: [AnswerOption]
    let correctAnswerIndex: Int

    init(from quiz: AssistChatMessage.QuizItem) {
        id = UUID()
        question = quiz.question
        options = quiz.answers.map { AnswerOption($0) }
        correctAnswerIndex = quiz.correctAnswerIndex
    }

    init(question: String, options: [AnswerOption], correctAnswerIndex: Int) {
        id = UUID()
        self.question = question
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
    }
}

extension AssistQuizModel {
    struct AnswerOption: Identifiable, Equatable {
        let id: UUID
        let answer: String

        init(_ answer: String) {
            id = UUID()
            self.answer = answer
        }
    }
}

extension AssistQuizModel {
    static var mock: [AssistQuizModel] {
        [
            .init(
                question: "What is the capital of Egypt?",
                options: [
                    .init("Alex"),
                    .init("Cairo"),
                    .init("Mansura"),
                    .init("Giza")
                ],
                correctAnswerIndex: 2
            ),
            .init(
                question: "Is the Earth flat?",
                options: [
                    .init("True"),
                    .init("False")
                ],
                correctAnswerIndex: 2
            ),
            .init(
                question: "Which of these is a programming language?",
                options: [
                    .init("PhotoShop"),
                    .init("HTML"),
                    .init("CSS"),
                    .init("Photoshop"),
                    .init("Python")
                ],
                correctAnswerIndex: 5
            ),
            .init(
                question: "What is the smallest planet in our solar system?",
                options: [
                    .init("Earth, our home, which is not the smallest planet"),
                    .init("Mercury, the smallest planet and closest to the Sun"),
                    .init("Mars, known as the Red Planet but larger than Mercury"),
                    .init("Venus, similar in size to Earth but still not the smallest")
                ],
                correctAnswerIndex: 2
            )
        ]
    }
}
