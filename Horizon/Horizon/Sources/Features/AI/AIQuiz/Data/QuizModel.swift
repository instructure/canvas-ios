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

struct QuizModel {
    // MARK: - Properties

    let id: Int
    let question: String
    var options: [AnswerOption]
    let correctAnswer: Int

    mutating func validateSelectedAnswer(id: Int) {
        if let index = options.firstIndex(where: { $0.id == id }) {
            options[index].isCorrect = correctAnswer == id
        }

        if let index = options.firstIndex(where: { $0.id == correctAnswer }) {
            options[index].isCorrect = true
        }
    }
}

extension QuizModel {
    struct AnswerOption: Identifiable, Equatable {
        let id: Int
        let answer: String
        var isCorrect: Bool?
    }
}

extension QuizModel {
    static var mock: [QuizModel] {
        [
            .init(
                id: 1,
                question: "What is the capital of Egypt?",
                options: [
                    .init(id: 1, answer: "Alex"),
                    .init(id: 2, answer: "Cairo"),
                    .init(id: 3, answer: "Mansura"),
                    .init(id: 4, answer: "Giza")
                ],
                correctAnswer: 2
            ),
            .init(
                id: 2,
                question: "Is the Earth flat?",
                options: [
                    .init(id: 1, answer: "True"),
                    .init(id: 2, answer: "False")
                ],
                correctAnswer: 2
            ),
            .init(
                id: 3,
                question: "Which of these is a programming language?",
                options: [
                    .init(id: 1, answer: "PhotoShop"),
                    .init(id: 2, answer: "HTML"),
                    .init(id: 3, answer: "CSS"),
                    .init(id: 4, answer: "Photoshop"),
                    .init(id: 5, answer: "Python")
                ],
                correctAnswer: 5
            ),
            .init(
                id: 4,
                question: "What is the smallest planet in our solar system?",
                options: [
                    .init(id: 1, answer: "Earth, our home, which is not the smallest planet"),
                    .init(id: 2, answer: "Mercury, the smallest planet and closest to the Sun"),
                    .init(id: 3, answer: "Mars, known as the Red Planet but larger than Mercury"),
                    .init(id: 4, answer: "Venus, similar in size to Earth but still not the smallest")
                ],
                correctAnswer: 2
            )
        ]
    }
}
