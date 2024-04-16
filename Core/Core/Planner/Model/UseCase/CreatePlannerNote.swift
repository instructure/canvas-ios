//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public class CreatePlannerNote: APIUseCase {
    public typealias Model = Plannable
    public let request: PostPlannerNoteRequest
    public let cacheKey: String? = nil
    public var scope: Scope = Scope.all(orderBy: #keyPath(Plannable.details))

    public init(
        title: String? = nil,
        details: String? = nil,
        todoDate: Date,
        courseID: String? = nil,
        linkedObjectType: PlannableType = .planner_note,
        linkedObjectId: String? = nil
    ) {
        request = PostPlannerNoteRequest(body: PostPlannerNoteRequest.Body(
            title: title,
            details: details,
            todo_date: todoDate,
            course_id: courseID,
            linked_object_type: linkedObjectType,
            linked_object_id: linkedObjectId))
    }

    public func write(response: APINoContent?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
    }
}
