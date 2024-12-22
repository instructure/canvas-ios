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

public class GetK5HomeroomDueItemCount: CollectionUseCase {
    public typealias Model = K5HomeroomDueItemCount

    public var cacheKey: String? { "k5homeroom_dueItems" }
    public let request: GetPlannablesRequest
    public var scope: Scope { .all(orderBy: #keyPath(K5HomeroomDueItemCount.courseId)) }

    public init(courseIds: [String]) {
        let courseContextIds = courseIds.map { Core.Context(.course, id: $0).canvasContextID }
        let nowCalc = Date().inCalendar
        request = GetPlannablesRequest(userID: nil, startDate: nowCalc.startOfDay(), endDate: nowCalc.endOfDay(), contextCodes: courseContextIds, filter: "")
    }

    public func write(response: [APIPlannable]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let plannables = response else { return }

        for plannable in plannables {
            let model: K5HomeroomDueItemCount = client.first(where: #keyPath(K5HomeroomDueItemCount.courseId), equals: plannable.course_id?.rawValue) ?? client.insert()
            model.courseId = plannable.course_id?.rawValue ?? ""
            model.due += (plannable.submissions?.value1?.submitted == false ? 1 : 0)
        }
    }
}
