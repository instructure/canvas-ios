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
import Combine
import AppIntents
import SwiftUI

struct CourseQuery: EntityQuery {

    func entities(for identifiers: [CourseEntity.ID]) async throws -> [CourseEntity] {
        guard
            let domain = identifiers.first?.domain,
            identifiers.allSatisfy({ $0.domain == domain })
        else { return [] }

        let interactor = CourseTotalGradeModel.interactor
        guard let currentDomain = interactor.domain else {
            // This is to signal loading
            return identifiers.toUnknownEntities
        }

        guard domain == currentDomain else { return [] }

        let courseIDs = identifiers.map(\.courseId)
        let fetched = await interactor
            .fetchCourses(ofIDs: courseIDs)
            .map { course in
                CourseEntity(
                    courseId: course.id,
                    courseName: course.name ?? "",
                    domain: domain
                )
            }

        if fetched.isNotEmpty { return fetched }

        // Respond with mock to indicate loading
        return identifiers.toUnknownEntities
    }

    func suggestedEntities() async throws -> [CourseEntity] {
        let interactor = CourseTotalGradeModel.interactor
        guard let domain = interactor.domain else { return [] }

        return try await interactor
            .fetchSuggestedCourses()
            .map { course in
                CourseEntity(
                    courseId: course.id,
                    courseName: course.name ?? "",
                    domain: domain
                )
            }
    }
}

// MARK: - Helpers

extension Array where Element == CourseEntity.ID {
    var toUnknownEntities: [CourseEntity] {
        return map { cid in
            return CourseEntity(
                courseId: cid.courseId,
                courseName: "",
                domain: cid.domain,
                isKnown: false
            )
        }
    }
}
