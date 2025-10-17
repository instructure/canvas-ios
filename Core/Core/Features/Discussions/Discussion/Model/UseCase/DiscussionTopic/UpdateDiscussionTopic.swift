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

class UpdateDiscussionTopic: UseCase {
    typealias Model = DiscussionTopic
    enum Request {
        case create(PostDiscussionTopicRequest)
        case update(PutDiscussionTopicRequest)
    }

    var cacheKey: String? { nil }
    let context: Context
    let topicID: String?
    let request: Request

    init(context: Context, topicID: String?, form: [PostDiscussionTopicRequest.DiscussionKey: APIFormDatum?]) {
        self.context = context
        self.topicID = topicID
        if let topicID = topicID {
            self.request = .update(PutDiscussionTopicRequest(context: context, topicID: topicID, form: form))
        } else {
            self.request = .create(PostDiscussionTopicRequest(context: context, form: form))
        }
    }

    func makeRequest(environment: AppEnvironment, completionHandler: @escaping (APIDiscussionTopic?, URLResponse?, Error?) -> Void) {
        switch request {
        case .create(let request):
            environment.api.makeRequest(request, callback: completionHandler)
        case .update(let request):
            environment.api.makeRequest(request, callback: completionHandler)
        }
    }

    func write(response: APIDiscussionTopic?, urlResponse: URLResponse?, to client: NSManagedObjectContext) {
        if let item = response { DiscussionTopic.save(item, in: client) }
    }
}
