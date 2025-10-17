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

class DeleteDiscussionTopic: APIUseCase {
    typealias Model = DiscussionTopic

    let context: Context
    let topicID: String

    var cacheKey: String? { nil }
    var request: DeleteDiscussionTopicRequest {
        DeleteDiscussionTopicRequest(context: context, topicID: topicID)
    }
    var scope: Scope { .where(#keyPath(DiscussionTopic.id), equals: topicID) }

    init(context: Context, topicID: String) {
        self.context = context
        self.topicID = topicID
    }

    func write(response: DeleteDiscussionTopicRequest.Response?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard response != nil else { return }
        client.delete(client.fetch(scope: scope) as [DiscussionTopic])
    }
}
