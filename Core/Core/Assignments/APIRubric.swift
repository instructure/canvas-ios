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

import Foundation

public struct APIRubric: Codable, Equatable {
    let id: ID
    let points: Double
    let description: String
    let long_description: String?
    let criterion_use_range: Bool
    let ratings: [APIRubricRating]?
    var assignmentID: String?
    var position: Int?
}

public struct APIRubricRating: Codable, Equatable {
    let id: ID
    let points: Double?
    let description: String
    let long_description: String
    var assignmentID: String?
    var position: Int?
}

public struct APIRubricSettings: Codable, Equatable {
    var hide_points: Bool
    var free_form_criterion_comments: Bool?
}

#if DEBUG
extension APIRubric {
    public static func make(
        id: ID = "1",
        points: Double = 25.0,
        description: String = "Effort",
        long_description: String? = "Did you even try?",
        criterion_use_range: Bool = false,
        ratings: [APIRubricRating]? = [ .make() ],
        assignmentID: String? = "1",
        position: Int? = nil
    ) -> APIRubric {
        return APIRubric(
            id: id,
            points: points,
            description: description,
            long_description: long_description,
            criterion_use_range: criterion_use_range,
            ratings: ratings,
            assignmentID: assignmentID,
            position: position
        )
    }
}

extension APIRubricRating {
    public static func make(
        id: ID = "1",
        points: Double? = 25.0,
        description: String = "Excellent",
        long_description: String = "Like the best!",
        assignmentID: String? = nil,
        position: Int? = nil
    ) -> APIRubricRating {
        return APIRubricRating(
            id: id,
            points: points,
            description: description,
            long_description: long_description,
            assignmentID: assignmentID,
            position: position
        )
    }
}

extension APIRubricAssessment {
    public static func make(
        submissionID: String? = "1",
        points: Double? = 25.0,
        comments: String? = "You failed at punctuation!",
        rating_id: String? = "1"
    ) -> APIRubricAssessment {
        return APIRubricAssessment(
            submissionID: submissionID,
            points: points,
            comments: comments,
            rating_id: rating_id
        )
    }
}

extension APIRubricSettings {
    public static func make(hides_points: Bool = false, free_form_criterion_comments: Bool? = nil) -> APIRubricSettings {
        return APIRubricSettings(hide_points: hides_points, free_form_criterion_comments: free_form_criterion_comments)
    }
}
#endif
