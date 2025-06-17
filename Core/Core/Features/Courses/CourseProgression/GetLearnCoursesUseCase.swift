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

public class GetLearnCoursesUseCase: APIUseCase {
    // MARK: - Typealias

    public typealias Model = CDHLearnCourse
    public typealias Request = GetCoursesProgressionRequest

    // MARK: - Properties

    public var cacheKey: String? {
        return "learn-courses"
    }

    private let userId: String

    public var request: GetCoursesProgressionRequest {
        .init(userId: userId, horizonCourses: true)
    }

    // MARK: - Init

    public init(userId: String) {
        self.userId = userId
    }

    // MARK: - Functions

    public func write(
        response: GetCoursesProgressionResponse?,
        urlResponse _: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        let enrollments = response?.data?.user?.enrollments ?? []
        enrollments.forEach { enrollment in
            CDHLearnCourse.save(enrollment, in: client)
        }
    }
}
