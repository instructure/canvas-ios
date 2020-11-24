//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public final class CourseSection: NSManagedObject, WriteableModel {
    public typealias JSON = APICourseSection

    @NSManaged public var courseID: String
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var startAt: Date?
    @NSManaged public var endAt: Date?
    @NSManaged var totalStudentsRaw: NSNumber?

    public var totalStudents: Int? {
        get { return totalStudentsRaw?.intValue }
        set { totalStudentsRaw = NSNumber(value: newValue) }
    }

    @discardableResult
    public static func save(_ item: APICourseSection, in context: NSManagedObjectContext) -> CourseSection {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(CourseSection.id), item.id.value)
        let model: CourseSection = context.fetch(predicate).first ?? context.insert()
        model.courseID = item.course_id.value
        model.id = item.id.value
        model.name = item.name
        model.startAt = item.start_at
        model.endAt = item.end_at
        model.totalStudents = item.total_students
        return model
    }

    @discardableResult
    public static func save(_ item: APICourse.SectionRef, courseID: String, in context: NSManagedObjectContext) -> CourseSection {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(CourseSection.id), item.id.value)
        let model: CourseSection = context.fetch(predicate).first ?? context.insert()
        model.courseID = courseID
        model.id = item.id.value
        model.name = item.name
        model.startAt = item.start_at
        model.endAt = item.end_at
        return model
    }
}
