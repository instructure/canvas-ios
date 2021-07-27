//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public class GetGradesCourses: CollectionUseCase {
    public typealias Model = Course

    let userID: String

    public init(userID: String) {
        self.userID = userID
    }

    public var cacheKey: String? { "users/\(userID)/courses" }
    public var request: GetCoursesRequest {
        GetCoursesRequest(perPage: 100)
    }

    public var scope: Scope { Scope(
        predicate: NSPredicate(format: "ANY %K == %@", #keyPath(Course.enrollments.userID), userID),
        order: [
            NSSortDescriptor(key: #keyPath(Course.name), ascending: true, naturally: true),
            NSSortDescriptor(key: #keyPath(Course.id), ascending: true),
        ]
    ) }
}
