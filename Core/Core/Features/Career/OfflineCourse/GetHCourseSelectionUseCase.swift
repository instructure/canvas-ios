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

import CoreData
import Foundation

public final class GetHCourseSelectionUseCase: APIUseCase {
    // MARK: - Typealias

    public typealias Model = CDHCourseSelection
    public typealias Request = GetHCourseSelectionRequest

    // MARK: - Properties

    public var cacheKey: String? { "Get-Course-Selection" }
    private let userId: String
    private let horizonCourses: Bool?

    public var request: GetHCourseSelectionRequest {
        .init(userId: userId, horizonCourses: horizonCourses)
    }

    public var scope: Scope { .all }

    public init(
        userId: String,
        horizonCourses: Bool? = true
    ) {
        self.userId = userId
        self.horizonCourses = horizonCourses
    }

    // MARK: - Functions

    public func write(
        response: GetHCourseSelectionResponse?,
        urlResponse _: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        let enrollments = response?.data.legacyNode.enrollments ?? []
        enrollments.forEach { enrollment in
            CDHCourseSelection.save(apiEntity: enrollment, in: client)
        }
    }
}
