//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

struct GetAnnouncementsUseCase: CollectionUseCase {
    public typealias Model = DiscussionTopic
    public typealias Response = Request.Response

    public var cacheKey: String? {
        var cacheKey = "announcements(\(courseContextIds.sorted().joined(separator: ",")))"
        if let activeOnly = activeOnly {
            cacheKey += ",activeOnly=\(activeOnly)"
        }
        if let latestOnly = latestOnly {
            cacheKey += ",latestOnly=\(latestOnly)"
        }
        if let startDate = startDate {
            cacheKey += ",startDate=\(startDate.timeIntervalSince1970)"
        }
        if let endDate = endDate {
            cacheKey += ",endDate=\(endDate.timeIntervalSince1970)"
        }
        return cacheKey
    }
    public var request: GetAllAnnouncementsRequest {
        GetAllAnnouncementsRequest(
            contextCodes: courseContextIds,
            activeOnly: activeOnly,
            latestOnly: latestOnly,
            startDate: startDate,
            endDate: endDate
        )
    }
    public var scope: Scope { .all(orderBy: #keyPath(DiscussionTopic.postedAt), ascending: false) }

    private let courseContextIds: [String]

    private let activeOnly: Bool?
    private let latestOnly: Bool?
    private let startDate: Date?
    private let endDate: Date?

    public init(
        courseIds: [String],
        activeOnly: Bool? = true,
        latestOnly: Bool? = true,
        startDate: Date? = nil,
        endDate: Date? = nil
    ) {
        courseContextIds = courseIds.map { Core.Context(.course, id: $0).canvasContextID }
        self.activeOnly = activeOnly
        self.latestOnly = latestOnly
        self.startDate = startDate
        self.endDate = endDate
    }
}
