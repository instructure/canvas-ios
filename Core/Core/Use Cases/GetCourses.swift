//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public class GetCourses: CollectionUseCase {
    public typealias Model = Course

    let showFavorites: Bool
    let enrollmentState: GetCoursesRequest.EnrollmentState?
    let perPage: Int

    public var scope: Scope {
        if showFavorites {
            return Scope.where(#keyPath(Course.isFavorite), equals: true, orderBy: #keyPath(Course.name), ascending: true, naturally: true)
        }
        if let enrollmentState = enrollmentState {
            let predicate = NSPredicate(format: "ANY %K == %@", #keyPath(Course.enrollments.stateRaw), enrollmentState.rawValue)
            return Scope(predicate: predicate, orderBy: #keyPath(Course.name), ascending: true, naturally: true)
        }
        return Scope.all(orderBy: #keyPath(Course.name), ascending: true, naturally: true)
    }

    public var request: GetCoursesRequest {
        return GetCoursesRequest(enrollmentState: enrollmentState, perPage: perPage)
    }

    public var cacheKey: String? {
        if let enrollmentState = enrollmentState {
            return "get-courses-\(enrollmentState)"
        }
        return "get-courses"
    }

    public init(showFavorites: Bool = false, enrollmentState: GetCoursesRequest.EnrollmentState? = .active, perPage: Int = 10) {
        self.showFavorites = showFavorites
        self.enrollmentState = enrollmentState
        self.perPage = perPage
    }
}
