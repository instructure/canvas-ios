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

public struct DSQuizQuestion: Codable {
    public let id: String
    public let quiz_id: String
    public let question_name: String
    public let question_type: String
    public let question_text: String
    public let points_possible: Int
    public let answers: [DSAnswer]
}

public struct DSAnswer: Codable {
    public let id: String?
    public let text: String?
    public let weight: Int?

    public init(id: String? = nil, text: String, weight: Int) {
        self.id = id
        self.text = text
        self.weight = weight
    }
}

public enum DSQuestionType: String, Encodable {
    case calculatedQuestion = "calculated_question"
    case essayQuestion = "essay_question"
    case fileUploadQuestion = "file_upload_question"
    case fillInMultipleBlanksQuestion = "fill_in_multiple_blanks_question"
    case matchingQuestion = "matching_question"
    case multipleAnswersQuestion = "multiple_answers_question"
    case multipleChoiceQuestion = "multiple_choice_question"
    case multipleDropdownsQuestion = "multiple_dropdowns_question"
    case numericalQuestion = "numerical_question"
    case shortAnswerQuestion = "short_answer_question"
    case textOnlyQuestion = "text_only_question"
    case trueFalseQuestion = "true_false_question"
}
