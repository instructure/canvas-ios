//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

class GetDiscussionView: CollectionUseCase {
    typealias Model = DiscussionEntry

    let context: Context
    let topicID: String

    var cacheKey: String? {
        "\(context.pathComponent)/discussions/\(topicID)/view"
    }
    var request: GetDiscussionViewRequest {
        GetDiscussionViewRequest(context: context, topicID: topicID)
    }
    var scope: Scope {
        Scope.where(
            #keyPath(DiscussionEntry.topicID),
            equals: topicID,
            sortDescriptors: [
                NSSortDescriptor(key: #keyPath(DiscussionEntry.createdAt), ascending: true, naturally: false),
                NSSortDescriptor(key: #keyPath(DiscussionEntry.id), ascending: true)
            ]
        )
    }

    init(context: Context, topicID: String) {
        self.context = context
        self.topicID = topicID
    }

    func write(response: APIDiscussionView?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let view = response else { return }
        for participant in view.participants {
            DiscussionParticipant.save(participant, in: client)
        }
        let unreadIDs = Set(view.unread_entries.map { $0.value })
        let forcedIDs = Set(view.forced_entries.map { $0.value })
        let entryRatings = view.entry_ratings
        for entry in view.view {
            DiscussionEntry.save(entry, topicID: topicID, unreadIDs: unreadIDs, forcedIDs: forcedIDs, entryRatings: entryRatings, in: client)
        }
        view.new_entries?.forEach { entry in
            let parent: DiscussionEntry? = client.first(where: #keyPath(DiscussionEntry.id), equals: entry.parent_id?.value)
            DiscussionEntry.save(entry, topicID: topicID, parent: parent, unreadIDs: unreadIDs, forcedIDs: forcedIDs, entryRatings: entryRatings, in: client)
        }
    }
}
