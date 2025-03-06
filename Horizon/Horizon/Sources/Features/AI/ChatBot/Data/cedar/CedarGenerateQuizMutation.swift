//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core

class CedarGenerateQuizMutation: APIGraphQLRequestable {
    let variables: GenerateQuizInput

    var path: String {
        "/graphql"
    }

    var headers: [String: String?] {
        [
            "x-apollo-operation-name": "\(Self.operationName)",
            HttpHeader.accept: "application/json"
        ]
    }

    public init(
        context: String,
        numberOfQuestions: Int = 1,
        numberOfOptionsPerQuestion: Int = 4,
        maxLengthOfQuestions: Int = 100
    ) {
        self.variables = GenerateQuizInput(
            context: context,
            numberOfQuestions: numberOfQuestions,
            numberOfOptionsPerQuestion: numberOfOptionsPerQuestion,
            maxLengthOfQuestions: maxLengthOfQuestions
        )
    }

    public static let operationName: String = "GenerateQuiz"
    public static var query: String = """
            mutation \(operationName)($input: GenerateQuizInput!) {
                generateQuiz(input: $input) {
                    question
                    options
                    result
                }
            }
        """

    typealias Response = QuizData

    struct GenerateQuizInput: Codable, Equatable {
        let context: String
        let numberOfQuestions: Int
        let numberOfOptionsPerQuestion: Int
        let maxLengthOfQuestions: Int
    }

    struct QuizData: Codable {
        let data: Quiz
    }

    struct Quiz: Codable {
        let generateQuiz: [QuizItem]
    }

    struct QuizItem: Codable {
        let question: String
        let options: [String]
        let result: Int
    }
}
