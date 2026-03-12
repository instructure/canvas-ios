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

public struct LearningLibraryRecommendationRequest: APIGraphQLRequestable {
    public typealias Response = LearningLibraryRecommendationResponse
    public typealias Variables = Input
    // MARK: - Variables

    public struct Input: Codable, Equatable {}

    // MARK: - Properties

    public let variables: Input = .init()

    public var path: String { "/graphql" }

    public var headers: [String: String?] = [
        HttpHeader.accept: "application/json"
    ]

    public static let operationName: String = "LearningLibraryRecommendations"

    // MARK: - Init

    public init() { }

    // MARK: - Query

    public static var query: String {
        """
         query \(operationName) {
            learningRecommendations {
              recommendations {
                courseId
                primaryReason
                sourceContext {
                  sourceCourseId
                  sourceCourseName
                  sourceSkillName
                }
                popularityCount
                membership {
                  id
                  itemType
                  status
                  displayOrder
                  canvasCourse {
                    courseId
                    courseName
                    courseImageUrl
                    moduleCount
                    moduleItemCount
                    estimatedDurationMinutes
                  }
                  libraryId
                  programId
                  programCourseId
                  canvasModuleId
                  canvasModuleItemId
                  isBookmarked
                  completionPercentage
                  isEnrolledInCanvas
                  canvasEnrollmentId
                  createdAt
                  updatedAt
                }
              }
            }
          }
        """
    }
}
