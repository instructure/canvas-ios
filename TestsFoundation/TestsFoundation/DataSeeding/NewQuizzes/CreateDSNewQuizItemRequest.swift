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

import Core

// https://canvas.instructure.com/doc/api/quizzes.html#method.quizzes/quizzes_api.create
public struct CreateDSNewQuizItemRequest: APIRequestable {
    public typealias Response = DSNewQuizItem

    public let method = APIMethod.post
    public var path: String
    public let body: Body?

    public init(body: Body, courseId: String, quizId: String) {
        self.body = body
        self.path = "/api/quiz/v1/courses/\(courseId)/quizzes/\(quizId)/items"
    }
}

extension CreateDSNewQuizItemRequest {
    public struct RequestedDSNewQuizItem: Encodable {
        let entry_type: String
        let entry: DSEntry
        let scoring_data: DSScoringData
        let scoring_algorithm: String

        public init(entry_type: String = "Item",
                    entry: DSEntry,
                    scoring_data: DSScoringData,
                    scoring_algorithm: DSScoringAlgorithm) {
            self.entry_type = entry_type
            self.entry = entry
            self.scoring_data = scoring_data
            self.scoring_algorithm = scoring_algorithm.rawValue
        }
    }

    public struct Body: Encodable {
        let course_id: String
        let assignment_id: String
        let item: RequestedDSNewQuizItem
    }

    public struct DSEntry: Encodable {
        let title: String
        let item_body: String
        let interaction_type_slug: String
        let interaction_data: DSInteractionData

        public init(title: String,
                    item_body: String,
                    interaction_type_slug: DSInteractionTypeSlug,
                    interaction_data: DSInteractionData) {
            self.title = title
            self.item_body = item_body
            self.interaction_type_slug = interaction_type_slug.rawValue
            self.interaction_data = interaction_data
        }
    }

    public struct DSScoringData: Encodable {
        // TrueFalse only
        let value: Bool?

        public init(value: Bool?) {
            self.value = value
        }
    }

    public struct DSInteractionData: Encodable {
        // TrueFalse
        public let true_choice: String?
        public let false_choice: String?

        public init(true_choice: String? = nil,
                    false_choice: String? = nil) {
            self.true_choice = true_choice
            self.false_choice = false_choice
        }
    }
}

public enum DSInteractionTypeSlug: String {
    case trueFalse = "true-false"
    case categorization = "categorization"
    case matching = "matching"
    case fileUpload = "file-upload"
    case formula = "formula"
    case ordering = "ordering"
    case fillInTheBlank = "rich-fill-blank"
    case hotSpot = "hot-spot"
    case multipleChoice = "choice"
    case multipleAnswer = "multi-answer"
    case numeric = "numeric"
    case essay = "essay"
}

public enum DSScoringAlgorithm: String {
    case trueFalse = "Equivalence"
}
