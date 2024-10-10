//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public class GetLatestAnnouncements: CollectionUseCase {
    public typealias Model = LatestAnnouncement
    public typealias Response = [APIDiscussionTopic]

    public var cacheKey: String? { "announcements(\(courseContextIds.sorted().joined(separator: ",")))" }
    public var request: GetAllAnnouncementsRequest { GetAllAnnouncementsRequest(contextCodes: courseContextIds, activeOnly: true, latestOnly: true) }
    public var scope: Scope { .all(orderBy: #keyPath(LatestAnnouncement.postedAt), ascending: false) }

    private let courseContextIds: [String]

    public init(courseIds: [String]) {
        courseContextIds = courseIds.map { Core.Context(.course, id: $0).canvasContextID }
    }
}
