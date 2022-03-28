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

import CoreData

final class DashboardCard: NSManagedObject {
    typealias JSON = APIDashboardCard

    @NSManaged var course: Course?
    @NSManaged var contextColor: ContextColor?
    @NSManaged var courseCode: String
    @NSManaged var enrollmentType: String
    @NSManaged var href: URL?
    @NSManaged var id: String
    @NSManaged var imageURL: URL?
    @NSManaged var isHomeroom: Bool
    @NSManaged var isK5Subject: Bool
    /** Teacher assigned hex color for K5 courses */
    @NSManaged var k5Color: String?
    @NSManaged var longName: String
    @NSManaged var originalName: String
    @NSManaged var position: Int
    @NSManaged var shortName: String
    @NSManaged var subtitle: String
    @NSManaged var term: String?

    var color: UIColor { contextColor?.color ?? .ash }

    var isTeacherEnrollment: Bool {
        let teacherRoles = ["teacher", "ta"]
        return teacherRoles.contains(where: enrollmentType.lowercased().contains)
    }

    var shouldShow: Bool {
        guard let enrollments = course?.enrollments else { return false }
        return enrollments.contains { enrollment in
            enrollment.state == .active
        }
    }

    @discardableResult
    static func save(_ item: APIDashboardCard, position: Int, in context: NSManagedObjectContext) -> Self {
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

class GetDashboardCards: CollectionUseCase {
    typealias Model = DashboardCard

    var cacheKey: String? { "dashboard/dashboard_cards" }
    var request: GetDashboardCardsRequest { GetDashboardCardsRequest() }
    var scope: Scope { .all(orderBy: #keyPath(DashboardCard.position)) }

    func write(response: [APIDashboardCard]?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        response?.enumerated().forEach {
            Model.save($0.element, position: $0.offset, in: client)
        }
    }
}
