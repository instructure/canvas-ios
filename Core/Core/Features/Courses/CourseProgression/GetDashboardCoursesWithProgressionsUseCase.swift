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

import Foundation
import CoreData

public class GetDashboardCoursesWithProgressionsUseCase: APIUseCase {

    // MARK: - Typealias

    public typealias Model = CDDashboardCourse
    public typealias Request = GetCoursesProgressionRequest

    // MARK: - Properties

    public var cacheKey: String? {
        return "Courses-Progression"
    }
    private let courseId: String?
    private let userId: String

    public var request: GetCoursesProgressionRequest {
        .init(userId: userId)
    }

    // MARK: - Init

    public init(userId: String, courseId: String? = nil) {
        self.userId = userId
        self.courseId = courseId
    }

    // MARK: - Functions

    public func write(
        response: GetCoursesProgressionResponse?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        let enrollments = response?.data?.user?.enrollments ?? []
        enrollments.forEach { enrollment in
            CDDashboardCourse.save(enrollment, in: client)
        }
    }

    public var scope: Scope {
        if let courseId = courseId {
            return .where(#keyPath(CDDashboardCourse.courseID), equals: courseId)
        }
        return .all
    }

}
