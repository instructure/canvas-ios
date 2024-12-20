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

public final class LatestAnnouncement: NSManagedObject {
    @NSManaged public var contextCode: String
    @NSManaged public var message: String
    @NSManaged public var title: String
    @NSManaged public var postedAt: Date
}

extension LatestAnnouncement: WriteableModel {
    public typealias JSON = APIDiscussionTopic

    @discardableResult
    public static func save(_ item: APIDiscussionTopic, in context: NSManagedObjectContext) -> LatestAnnouncement {
        let model: LatestAnnouncement = context.first(where: #keyPath(LatestAnnouncement.contextCode), equals: item.context_code) ?? context.insert()
        model.contextCode = item.context_code ?? ""
        model.message = item.message ?? ""
        model.title = item.title ?? ""
        model.postedAt = item.posted_at ?? Date.distantPast
        return model
    }
}
