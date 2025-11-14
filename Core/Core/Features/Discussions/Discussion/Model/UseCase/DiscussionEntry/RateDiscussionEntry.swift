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

class RateDiscussionEntry: APIUseCase {
    var cacheKey: String? { nil }
    let context: Context
    let request: PostDiscussionEntryRatingRequest
    let topicID: String
    let entryID: String
    let isLiked: Bool

    init(context: Context, topicID: String, entryID: String, isLiked: Bool) {
        self.context = context
        self.request = PostDiscussionEntryRatingRequest(context: context, topicID: topicID, entryID: entryID, isLiked: isLiked)
        self.topicID = topicID
        self.entryID = entryID
        self.isLiked = isLiked
    }

    func write(response: APINoContent?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard (urlResponse as? HTTPURLResponse)?.statusCode == 204 else { return }
        let entry: DiscussionEntry? = client.first(where: #keyPath(DiscussionEntry.id), equals: entryID)
        entry?.isLikedByMe = isLiked
        entry?.likeCount += isLiked ? 1 : -1
    }
}
