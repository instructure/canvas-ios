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

public final class CDAllCoursesGroupItem: NSManagedObject, WriteableModel {
    public typealias JSON = APIGroup

    @NSManaged public var id: String
    @NSManaged public var name: String

    @NSManaged public var contextRaw: String?

    @NSManaged public var courseID: String?
    @NSManaged public var courseName: String?
    @NSManaged public var courseTermName: String?
    @NSManaged public var courseRoles: String?

    @NSManaged public var concluded: Bool
    @NSManaged public var isFavorite: Bool

    public var context: Context? {
        get { contextRaw.flatMap { Context(canvasContextID: $0) } }
        set { contextRaw = newValue?.canvasContextID }
    }

    public var canvasContextID: String {
        Context(.group, id: id).canvasContextID
    }

    @discardableResult
    public static func save(_ item: APIGroup, in context: NSManagedObjectContext) -> CDAllCoursesGroupItem {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(CDAllCoursesGroupItem.id), item.id.value)
        let model: CDAllCoursesGroupItem = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.name = item.name

        model.courseID = item.course_id?.value
        if let id = model.courseID, let course: Course = context.first(where: #keyPath(Course.id), equals: id) {
            model.courseID = item.course_id?.value
            model.courseID = course.name
            model.courseTermName = course.termName
            model.courseRoles = course.roles
        }

        model.concluded = item.concluded
        model.isFavorite = item.is_favorite ?? true

        return model
    }
}
