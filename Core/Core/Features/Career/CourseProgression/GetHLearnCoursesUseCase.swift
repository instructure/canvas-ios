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

import CoreData
import Foundation

public class GetHLearnCoursesUseCase: APIUseCase {
    // MARK: - Typealias

    public typealias Model = CDHLearnCourse
    public typealias Request = GetHLearnCoursesProgressionRequest

    // MARK: - Properties

    public var cacheKey: String? {
        return "learn-courses"
    }

    private let userId: String
    /// - true: Fetch only horizon courses
    /// - false: Fetch only non-horizon courses
    /// - nil: Fetch both
    private let horizonCourses: Bool?

    public var request: GetHLearnCoursesProgressionRequest {
        .init(userId: userId, horizonCourses: horizonCourses)
    }

    // MARK: - Init

    public init(userId: String, horizonCourses: Bool? = true) {
        self.userId = userId
        self.horizonCourses = horizonCourses
    }

    // MARK: - Functions

    public func write(
        response: GetHCoursesProgressionResponse?,
        urlResponse _: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        let enrollments = response?.data?.user?.enrollments ?? []
        enrollments.forEach { enrollment in
            CDHLearnCourse.save(enrollment, in: client)
        }
    }
}
