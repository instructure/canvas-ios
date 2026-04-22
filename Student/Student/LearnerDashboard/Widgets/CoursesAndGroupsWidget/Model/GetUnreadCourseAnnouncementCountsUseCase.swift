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

import Core
import CoreData
import Foundation

struct GetUnreadCourseAnnouncementCountsUseCase: APIUseCase {
    typealias Model = CDUnreadCourseAnnouncementCount
    typealias Request = GetUnreadAnnouncementsCountRequest

    var cacheKey: String? { "unread-course-announcement-counts" }
    var request: GetUnreadAnnouncementsCountRequest { .init() }
    var scope: Scope { .all }

    func write(
        response: GetUnreadAnnouncementsCountResponse?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        guard let response else { return }
        for course in response.data.allCourses {
            CDUnreadCourseAnnouncementCount.save(
                courseId: course._id,
                unreadCount: course.unreadAnnouncementCount,
                singleUnreadAnnouncementId: course.singleUnreadAnnouncementId,
                in: client
            )
        }
    }
}
