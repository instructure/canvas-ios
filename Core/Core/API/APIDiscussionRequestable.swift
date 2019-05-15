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

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics.create
struct PostDiscussionTopicRequest: APIRequestable {
    typealias Response = APIDiscussionTopic
    struct Body: Codable, Equatable {
        let title: String
        let message: String
        let published: Bool
        let assignment: APIAssignmentParameters?
    }

    let context: Context
    let body: Body?
    let method = APIMethod.post
    public var path: String {
        return "\(context.pathComponent)/discussion_topics"
    }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.add_entry
struct PostDiscussionEntryRequest: APIRequestable {
    typealias Response = APIDiscussionEntry
    struct Body: Codable, Equatable {
        let message: String
    }

    let context: Context
    let topicID: String
    let body: Body?
    let method = APIMethod.post
    public var path: String {
        return "\(context.pathComponent)/discussion_topics/\(topicID)/entries"
    }
}
