//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public final class InboxCourse: NSManagedObject, WriteableModel {
    public typealias JSON = APICourse

    @NSManaged public var name: String
    @NSManaged public var courseId: String

    // MARK: - Helper Properties

    public var context: Context { .init(.course, id: courseId) }

    #if DEBUG

    @discardableResult
    public static func save(_ apiEntity: APICourse, in context: NSManagedObjectContext) -> InboxCourse {
        let dbEntity: InboxCourse = context.first(where: #keyPath(InboxCourse.courseId),
                                                           equals: apiEntity.id.value) ?? context.insert()
        dbEntity.name = apiEntity.name ?? apiEntity.course_code ?? ""
        dbEntity.courseId = apiEntity.id.value
        return dbEntity
    }

    #endif
}
