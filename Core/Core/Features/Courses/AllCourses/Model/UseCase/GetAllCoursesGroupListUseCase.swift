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

public class GetAllCoursesGroupListUseCase: CollectionUseCase {
    public typealias Model = CDAllCoursesGroupItem

    public let context: Context
    public let cacheKey: String?
    public let request: GetGroupsRequest
    public let scope: Scope

    public init(context: Context = Context.currentUser) {
        self.context = context
        cacheKey = "allCoursesCourses-\(context.pathComponent)/groups"
        request = GetGroupsRequest(context: context)
        scope = .where(
            #keyPath(CDAllCoursesGroupItem.contextRaw),
            equals: context.canvasContextID,
            orderBy: #keyPath(CDAllCoursesGroupItem.name),
            naturally: true
        )
    }

    public func write(response: [APIGroup]?, urlResponse _: URLResponse?, to client: NSManagedObjectContext) {
        response?.forEach { item in
            let group = CDAllCoursesGroupItem.save(item, in: client)
            group.context = context
        }
    }
}
