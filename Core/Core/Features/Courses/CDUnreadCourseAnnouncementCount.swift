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
    @NSManaged public var course: Course?
    @NSManaged private var unreadAnnouncementIdsRaw: String

    public var unreadAnnouncementIds: Set<String> {
        get {
            let ids = unreadAnnouncementIdsRaw.components(separatedBy: ",").filter { !$0.isEmpty }
            return Set(ids)
        }
        set {
            // Sorting ensures deterministic storage — without it, the same logical set
            // could produce different raw strings across runs, causing CoreData to treat
            // an unchanged value as a dirty write and fire unnecessary change notifications.
            unreadAnnouncementIdsRaw = newValue.sorted().joined(separator: ",")
        }
    }

    public var unreadCount: Int { unreadAnnouncementIds.count }

    /// The ID of the single unread announcement, populated only when `unreadCount == 1`.
    /// Used to deep-link directly to the announcement instead of opening the full announcement list.
    public var singleUnreadAnnouncementId: String? {
        unreadCount == 1 ? unreadAnnouncementIds.first : nil
    }

    public static func removeAnnouncementId(_ announcementId: String, courseId: String, database: NSPersistentContainer) {
        database.performWriteTask { context in
            guard let entity: CDUnreadCourseAnnouncementCount = context.first(
                where: #keyPath(CDUnreadCourseAnnouncementCount.courseId),
                equals: courseId
            ) else { return }

            var ids = entity.unreadAnnouncementIds
            ids.remove(announcementId)
            entity.unreadAnnouncementIds = ids
            try? context.save()
        }
    }

    @discardableResult
    public static func save(
        courseId: String,
        unreadAnnouncementIds: [String],
        in context: NSManagedObjectContext
    ) -> CDUnreadCourseAnnouncementCount {
        let entity: CDUnreadCourseAnnouncementCount = context.first(
            where: #keyPath(CDUnreadCourseAnnouncementCount.courseId),
            equals: courseId
        ) ?? context.insert()
        entity.courseId = courseId
        entity.unreadAnnouncementIds = Set(unreadAnnouncementIds)
        entity.course = context.fetch(scope: .where(#keyPath(Course.id), equals: courseId)).first
        return entity
    }
}
