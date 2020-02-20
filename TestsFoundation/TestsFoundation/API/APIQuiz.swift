//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/quiz_questions.html#QuizQuestion
public struct APIQuizQuestion: Codable {
    public let id: String
    public let quiz_id: String
    public let position: Int?
    public let question_name: String
    public let question_type: QuizQuestionType
    public let question_text: String
    public let points_possible: Int
    public let correct_comments: String
    public let incorrect_comments: String
    public let neutral_comments: String
    public let answers: [APIQuizAnswer]?
    public let answer: APIQuizAnswerValue?
}

// https://canvas.instructure.com/doc/api/quiz_submission_questions.html#QuizSubmissionQuestion
public struct APIQuizSubmissionQuestion: Codable {
    public let id: String
    public let flagged: Bool
    public let answer: APIQuizAnswerValue?
    // public let answers: [APIQuizAnswer]?
}

// Not documented
public struct APIQuizAnswer: Codable {
    public let id: String
    public let text: String
    public let html: String
}

// https://canvas.instructure.com/doc/api/quiz_submission_questions.html#Question+Answer+Formats-appendix
public enum APIQuizAnswerValue: Codable {
    case double(Double)
    case string(String)
    case hash([String: String])
    case list([String])
    case matching([[String: String]])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String: String].self) {
            self = .hash(value)
        } else if let value = try? container.decode([String].self) {
            self = .list(value)
        } else {
            self = .matching(try container.decode([[String: String]].self))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .hash(let value):
            try container.encode(value)
        case .list(let value):
            try container.encode(value)
        case .matching(let value):
            try container.encode(value)
        }
    }
}
