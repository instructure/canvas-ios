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

@testable import Core
import XCTest

final class LearningLibraryRecommendationRequestTests: CoreTestCase {
    func testPath() {
        XCTAssertEqual(LearningLibraryRecommendationRequest().path, "/graphql")
    }

    func testHeader() {
        let request = LearningLibraryRecommendationRequest()
        XCTAssertEqual(request.headers.count, 1)
        XCTAssertEqual(request.headers.first?.key, "Accept")
        XCTAssertEqual(request.headers.first?.value, "application/json")
    }

    func testOperationName() {
        XCTAssertEqual(LearningLibraryRecommendationRequest.operationName, "LearningLibraryRecommendations")
    }

    func testVariables() {
        let request = LearningLibraryRecommendationRequest()
        XCTAssertNotNil(request.variables)
    }

    func testQuery() {
        let query = """
         query LearningLibraryRecommendations {
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
        XCTAssertEqual(LearningLibraryRecommendationRequest.query, query)
    }

    func testResponseTyping() {
        let request = LearningLibraryRecommendationRequest()
        XCTAssertTrue(type(of: request).Response.self == LearningLibraryRecommendationResponse.self)
    }
}
