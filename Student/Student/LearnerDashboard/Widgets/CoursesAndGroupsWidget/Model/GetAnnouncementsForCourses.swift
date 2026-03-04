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
import Foundation

struct GetAnnouncementsForCourses: CollectionUseCase {
    typealias Model = DiscussionTopic
    typealias Response = Request.Response

    private static let distantPastDate = Cal.currentCalendar.date(from: DateComponents(year: 2000, month: 1, day: 1))
        ?? .distantPast

    var cacheKey: String? {
        "announcementsForCourses(\(courseContextIds.sorted().joined(separator: ",")))"
    }

    var request: GetAllAnnouncementsRequest {
        GetAllAnnouncementsRequest(
            contextCodes: courseContextIds,
            startDate: Self.distantPastDate,
            endDate: Clock.now
        )
    }

    var scope: Scope {
        Scope(
            predicate: .and(
                NSPredicate(\DiscussionTopic.isAnnouncement, equals: true),
                NSPredicate(\DiscussionTopic.canvasContextID, isContainedIn: courseContextIds)
            ),
            orderBy: \DiscussionTopic.postedAt,
            ascending: false
        )
    }

    private let courseContextIds: [String]

    init(courseContextIds: [String]) {
        self.courseContextIds = courseContextIds
    }
}
