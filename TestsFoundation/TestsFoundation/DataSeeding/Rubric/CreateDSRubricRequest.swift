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

import Core

// https://canvas.instructure.com/doc/api/rubrics.html#method.rubrics.create
public struct CreateDSRubricRequest: APIRequestable {
    public typealias Response = DSRubricResponse

    public let method = APIMethod.post
    public var path: String
    public let body: Body?

    public init(body: Body, course: DSCourse) {
        self.body = body
        self.path = "courses/\(course.id)/rubrics"
    }
}

extension CreateDSRubricRequest {
    public struct RequestedDSRubric: Encodable {
        let title: String
        let points_possible: Float
        let criteria: [String: RubricCriteria]
        let description: String?

        public init(title: String = "Rubric Title",
                    pointsPossible: Float = 1,
                    criteria: [String: RubricCriteria],
                    description: String? = nil) {
            self.title = title
            self.points_possible = pointsPossible
            self.criteria = criteria
            self.description = description
        }
    }

    public struct RequestedDSRubricAssociation: Encodable {
        let association_id: String
        let association_type: String
        let purpose: String

        public init(associationId: String, associationType: DSRubricAssociationType, purpose: String) {
            self.association_id = associationId
            self.association_type = associationType.rawValue
            self.purpose = purpose
        }
    }

    public struct Body: Encodable {
        let title: String
        let points_possible: Float
        let rubric_association_id: String
        let rubric: RequestedDSRubric
        let rubric_association: RequestedDSRubricAssociation
    }

    public struct RubricCriteria: Encodable {
        let description: String
        let long_description: String?
        let points: Float
        let ratings: [String: RubricCriteriaRating]
    }

    public struct RubricCriteriaRating: Encodable {
        let points: Float
        let description: String
    }
}

public enum DSRubricAssociationType: String {
    case course = "Course"
    case assignment = "Assignment"
    case account = "Account"
}
