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

public final class DashboardCard: NSManagedObject {
    typealias JSON = APIDashboardCard

    @NSManaged public var course: Course?
    @NSManaged public var contextColor: ContextColor?
    @NSManaged public var courseCode: String
    @NSManaged public var enrollmentType: String
    @NSManaged public var href: URL?
    @NSManaged public var id: String
    @NSManaged public var imageURL: URL?
    @NSManaged public var isHomeroom: Bool
    @NSManaged public var isK5Subject: Bool
    /** Teacher assigned hex color for K5 courses */
    @NSManaged public var k5Color: String?
    @NSManaged public var longName: String
    @NSManaged public var originalName: String
    @NSManaged public var position: Int
    @NSManaged public var shortName: String
    @NSManaged public var subtitle: String
    @NSManaged public var term: String?

    public var color: UIColor { contextColor?.color.ensureContrast(against: .backgroundLightest) ?? .ash }

    public var isTeacherEnrollment: Bool {
        let teacherRoles = ["teacher", "ta"]
        return teacherRoles.contains(where: enrollmentType.lowercased().contains)
    }

    public var shouldShow: Bool {
        guard let enrollments = course?.enrollments else { return false }
        return enrollments.contains { enrollment in
            enrollment.state == .active
        }
    }

    public var isAvailableOffline: Bool {
        guard let selections = AppEnvironment.shared.userDefaults?.offlineSyncSelections else { return true }
        return selections.contains { $0.contains("courses/\(id)") }
    }

    @discardableResult
    public static func save(_ item: APIDashboardCard, position: Int, in context: NSManagedObjectContext) -> Self {
        let model: Self = context.first(where: #keyPath(DashboardCard.id), equals: item.id.value) ?? context.insert()
        model.courseCode = item.courseCode
        model.enrollmentType = item.enrollmentType
        model.href = URL(string: item.href)
        model.id = item.id.value
        model.imageURL = item.image.flatMap { URL(string: $0) }
        model.isHomeroom = item.isHomeroom ?? false
        model.isK5Subject = item.isK5Subject ?? false
        model.k5Color = item.color
        model.longName = item.longName
        model.originalName = item.originalName
        model.position = item.position ?? position
        model.shortName = item.shortName
        model.subtitle = item.subtitle
        model.term = item.term

        if let contextColor: ContextColor = context.fetch(scope: .where(#keyPath(ContextColor.canvasContextID), equals: "course_\(model.id)")).first {
            model.contextColor = contextColor
        }

        if let course: Course = context.fetch(scope: .where(#keyPath(Course.id), equals: model.id)).first {
            model.course = course
        }

        return model
    }
}
