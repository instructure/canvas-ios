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

import Core
import CoreData

public class GetWidgetAnnouncements: CollectionUseCase {
    public static let Timeout: TimeInterval = 15 * 60 // 15 minutes
    public typealias Model = CDWidgetAnnouncement
    public var cacheKey: String? {
        "announcements?courses=[\(courseContextCodes.joined(separator: ","))]"
    }
    public var request: GetAllAnnouncementsRequest {
        GetAllAnnouncementsRequest(contextCodes: courseContextCodes)
    }
    public var scope: Scope {
        .all(orderBy: #keyPath(CDWidgetAnnouncement.date))
    }
    public var ttl: TimeInterval {
        Self.Timeout
    }

    private let courseContextCodes: [String]

    public init(courseContextCodes: [String]) {
        self.courseContextCodes = courseContextCodes.sorted()
    }

    public func write(
        response: [APIDiscussionTopic]?,
        urlResponse: URLResponse?,
        to client: NSManagedObjectContext
    ) {
        response?.enumerated().forEach {
            CDWidgetAnnouncement.save($0.element, in: client)
        }
    }
}
