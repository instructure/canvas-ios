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

public class GetK5HomeroomMissingSubmissionsCount: CollectionUseCase {
    public typealias Model = K5HomeroomMissingSubmissionsCount

    public var cacheKey: String? { "k5homeroom_missingSubmissions" }
    public let request: GetMissingSubmissionsRequest
    public var scope: Scope { .all(orderBy: #keyPath(K5HomeroomMissingSubmissionsCount.courseId)) }

    public init(courseIds: [String]) {
        request = GetMissingSubmissionsRequest(courseIds: courseIds, includes: [.planner_overrides])
    }

    public func write(response: [APIAssignment]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let assignments = response else { return }

        for assignment in assignments {
            let model: K5HomeroomMissingSubmissionsCount = client.first(where: #keyPath(K5HomeroomMissingSubmissionsCount.courseId), equals: assignment.course_id.rawValue) ?? client.insert()
            model.courseId = assignment.course_id.rawValue
            model.missing += (assignment.planner_override?.dismissed == true ? 0 : 1)
        }
    }
}
