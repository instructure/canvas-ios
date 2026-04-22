//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

public final class CDUnreadCourseAnnouncementCount: NSManagedObject {
    @NSManaged public var courseId: String
    @NSManaged public var unreadCount: Int
    /// The ID of the single unread announcement, populated only when `unreadCount == 1`.
    /// Used to deep-link directly to the announcement instead of opening the full announcement list.
    @NSManaged public var singleUnreadAnnouncementId: String?
    @NSManaged public var course: Course?

    @discardableResult
    public static func save(
        courseId: String,
        unreadCount: Int,
        singleUnreadAnnouncementId: String?,
        in context: NSManagedObjectContext
    ) -> CDUnreadCourseAnnouncementCount {
        let entity: CDUnreadCourseAnnouncementCount = context.first(
            where: #keyPath(CDUnreadCourseAnnouncementCount.courseId),
            equals: courseId
        ) ?? context.insert()
        entity.courseId = courseId
        entity.unreadCount = unreadCount
        entity.singleUnreadAnnouncementId = singleUnreadAnnouncementId
        entity.course = context.fetch(scope: .where(#keyPath(Course.id), equals: courseId)).first
        return entity
    }
}
