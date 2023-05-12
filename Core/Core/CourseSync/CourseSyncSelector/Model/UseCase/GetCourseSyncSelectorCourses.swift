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

public class GetCourseSyncSelectorCourses: CollectionUseCase {
    public typealias Model = CourseSyncSelectorCourse

    public var cacheKey: String? { "courseSyncSelectorCourse" }
    public let request: GetCurrentUserCoursesRequest
    public let scope: Scope = .all(orderBy: #keyPath(CourseSyncSelectorCourse.name))

    public init() {
        request = GetCurrentUserCoursesRequest(
            enrollmentState: .active,
            state: [.current_and_concluded],
            includes: [.tabs]
        )
    }

    public func write(response: [APICourse]?, urlResponse _: URLResponse?, to client: NSManagedObjectContext) {
        guard let response else { return }
        response.forEach {
            CourseSyncSelectorCourse.save($0, in: client)
        }
    }
}
