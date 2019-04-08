//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation
import CoreData

public final class DiscussionTopic: NSManagedObject, WriteableModel {
    public typealias JSON = APIDiscussionTopic

    @NSManaged public var id: String
    @NSManaged public var title: String?
    @NSManaged public var message: String?
    @NSManaged public var htmlUrl: URL?
    @NSManaged public var postedAt: Date?
    @NSManaged public var lastReplyAt: Date?
    @NSManaged public var discussionSubEntryCount: Int
    @NSManaged public var published: Bool
    @NSManaged public var assignment: Assignment?

    @discardableResult
    public static func save(_ item: APIDiscussionTopic, in context: PersistenceClient) -> DiscussionTopic {
        let predicate = NSPredicate(format: "%K == %@", #keyPath(DiscussionTopic.id), item.id.value)
        let model: DiscussionTopic = context.fetch(predicate).first ?? context.insert()
        model.id = item.id.value
        model.title = item.title
        model.htmlUrl = item.html_url
        model.postedAt = item.posted_at
        model.lastReplyAt = item.last_reply_at
        model.discussionSubEntryCount = item.discussion_subentry_count
        model.published = item.published
        return model
    }
}
