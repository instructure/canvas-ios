//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation
@testable import Core

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
