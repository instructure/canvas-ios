//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

public struct LearningLibraryRecommendationResponse: Codable {
    public let data: DataContainer

    public struct DataContainer: Codable {
       public let learningRecommendations: LearningRecommendations
    }

    public struct LearningRecommendations: Codable {
       public let recommendations: [Recommendation]
    }

   public struct Recommendation: Codable {
       public let courseID, primaryReason: String
       let popularityCount: Int
       public let sourceContext: SourceContext?
       public let membership: LearningLibraryItemsResponse

       enum CodingKeys: String, CodingKey {
            case courseID = "courseId"
            case primaryReason, popularityCount, sourceContext, membership
        }
    }

   public struct SourceContext: Codable {
       public let sourceCourseID, sourceCourseName: String?
       public let sourceSkillName: String?

        enum CodingKeys: String, CodingKey {
            case sourceCourseID = "sourceCourseId"
            case sourceCourseName, sourceSkillName
        }
    }
}
