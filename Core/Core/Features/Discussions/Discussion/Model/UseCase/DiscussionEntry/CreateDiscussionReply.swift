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

class CreateDiscussionReply: APIUseCase {
    typealias Model = DiscussionEntry

    var cacheKey: String? { nil }
    let context: Context
    let request: PostDiscussionEntryRequest
    let topicID: String

    init(context: Context, topicID: String, entryID: String? = nil, message: String, attachment: URL? = nil) {
        self.context = context
        self.request = PostDiscussionEntryRequest(context: context, topicID: topicID, entryID: entryID, message: message, attachment: attachment)
        self.topicID = topicID
    }

    func write(response: APIDiscussionEntry?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard let item = response else { return }
        DiscussionEntry.save(
            item,
            topicID: topicID,
            parent: client.first(where: #keyPath(DiscussionEntry.id), equals: item.parent_id?.value),
            in: client
        )
        if context.contextType == .course {
            NotificationCenter.default.post(moduleItem: .discussion(topicID), completedRequirement: .contribute, courseID: context.id)
        }
        NotificationCenter.default.post(name: .moduleItemRequirementCompleted, object: nil)
    }
}
