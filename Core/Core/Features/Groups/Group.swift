//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
import SwiftUI

public final class Group: NSManagedObject, WriteableModel {
    public typealias JSON = APIGroup

    @NSManaged public var avatarURL: URL?
    @NSManaged public var canCreateAnnouncement: Bool
    @NSManaged public var canCreateDiscussionTopic: Bool
    @NSManaged public var concluded: Bool
    @NSManaged public var contextColor: ContextColor?
    @NSManaged public var contextRaw: String?
    @NSManaged public var course: Course?
    @NSManaged public var courseID: String?
    @NSManaged public var groupCategoryID: String
    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var showOnDashboard: Bool
    @NSManaged public var isFavorite: Bool

    public var context: Context? {
        get { contextRaw.flatMap { Context(canvasContextID: $0) } }
        set { contextRaw = newValue?.canvasContextID }
    }

    public var canvasContextID: String {
        Context(.group, id: id).canvasContextID
    }

    public var color: UIColor { contextColor?.color ?? .textDark }

    public var isActive: Bool {
        if courseID == nil { return true }
        guard let course, let enrollments = course.enrollments else {
            return false
        }

        return enrollments.contains(where: {$0.state == .active}) && !course.isPastEnrollment && course.isPublished
    }

    @discardableResult
    public static func save(_ item: APIGroup, in context: NSManagedObjectContext) -> Group {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(Group.id), item.id.value)
        let model: Group = context.fetch(predicate).first ?? context.insert()
        model.avatarURL = item.avatar_url
        model.concluded = item.concluded
        model.courseID = item.course_id?.value
        model.groupCategoryID = item.group_category_id.value
        model.id = item.id.value
        model.name = item.name
        model.showOnDashboard = !item.concluded

        // `is_favorite` always has value when retrieved via `/api/v1/{context}/groups` api,
        // while for api `/api/v1/users/self/favorites/groups`, it always received with no value.
        // That's why we can assume the value to be `true` if not present.
        model.isFavorite = item.is_favorite ?? true

        if let contextColor: ContextColor = context.fetch(scope: .where(#keyPath(ContextColor.canvasContextID), equals: model.canvasContextID)).first {
            model.contextColor = contextColor
        } else if let courseID = model.courseID,
           let contextColor: ContextColor = context.fetch(scope: .where(#keyPath(ContextColor.canvasContextID), equals: Context(.course, id: courseID).canvasContextID)).first {
            model.contextColor = contextColor
        }

        if let permissions = item.permissions {
            model.canCreateAnnouncement = permissions.create_announcement
            model.canCreateDiscussionTopic = permissions.create_discussion_topic
        }

        if let id = model.courseID, let course: Course = context.first(where: #keyPath(Course.id), equals: id) {
            model.course = course
        }

        return model
    }
}
