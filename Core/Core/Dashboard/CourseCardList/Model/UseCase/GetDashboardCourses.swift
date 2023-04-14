//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public class GetDashboardCourses: CollectionUseCase {
    public typealias Model = Course

    public var cacheKey: String? { "get-dashboard-courses-\(enrollmentState)" }
    public let request: GetCurrentUserCoursesRequest
    public var scope: Scope {
        let order = [
            NSSortDescriptor(key: #keyPath(Course.name), ascending: true, naturally: true),
            NSSortDescriptor(key: #keyPath(Course.id), ascending: true),
        ]
        let predicate = NSPredicate(format: "ANY %K == %@", #keyPath(Course.enrollments.stateRaw), enrollmentState.rawValue)
        return Scope(predicate: predicate, order: order)
    }

    private let enrollmentState = GetCoursesRequest.EnrollmentState.active

    public init() {
        request = GetCurrentUserCoursesRequest(
            enrollmentState: enrollmentState,
            state: [.current_and_concluded],
            includes: GetCourseRequest.defaultIncludes
        )
    }

    public func write(response: [APICourse]?, urlResponse _: URLResponse?, to client: NSManagedObjectContext) {
        guard let response else { return }
        response.forEach {
            Course.save(
                $0,
                in: client
            )
        }
    }
}
