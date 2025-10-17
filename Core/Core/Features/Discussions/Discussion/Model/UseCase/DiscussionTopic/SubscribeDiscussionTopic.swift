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

class SubscribeDiscussionTopic: APIUseCase {
    typealias Model = DiscussionTopic

    var cacheKey: String? { nil }
    let context: Context
    let topicID: String
    let subscribed: Bool

    init(context: Context, topicID: String, subscribed: Bool) {
        self.context = context
        self.topicID = topicID
        self.subscribed = subscribed
    }

    var request: SubscribeDiscussionTopicRequest {
        SubscribeDiscussionTopicRequest(context: context, topicID: topicID, method: subscribed ? .put : .delete)
    }

    func write(response: APINoContent?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        guard (urlResponse as? HTTPURLResponse)?.statusCode == 204 else { return }
        let topic: DiscussionTopic? = client.first(where: #keyPath(DiscussionTopic.id), equals: topicID)
        topic?.subscribed = subscribed
    }
}
