//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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
// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.add_reply
struct PostDiscussionEntryRequest: APIRequestable {
    typealias Response = APIDiscussionEntry
    struct Body: Codable, Equatable {
        let message: String
    }

    let context: Context
    let topicID: String
    let body: Body?
    let method = APIMethod.post
    let replyId: String?

    init(context: Context, topicID: String, body: Body?, entryID: String? = nil) {
        self.context = context
        self.topicID = topicID
        self.body = body
        self.replyId = entryID
    }

    public var path: String {
        var path = "\(context.pathComponent)/discussion_topics/\(topicID)/entries"
        if let replyId = replyId {
            path.append("/\(replyId)/replies")
        }
        return path
    }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.entries
struct ListDiscussionEntriesRequest: APIRequestable {
    typealias Response = [APIDiscussionEntry]
    let context: Context
    let topicID: String
    public var path: String {
        return "\(context.pathComponent)/discussion_topics/\(topicID)/entries"
    }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.show
struct GetTopicRequest: APIRequestable {
    typealias Response = APIDiscussionTopic

    public enum Include: String, CaseIterable {
        case allDates = "all_dates"
        case sections
        case sectionsUserCount = "section_user_count"
        case overrides
    }

    let context: Context
    let topicID: String
    public static let defaultIncludes = [ Include.sections ]
    let include: [Include]

    init(context: Context, topicID: String, include: [Include] = defaultIncludes) {
        self.context = context
        self.topicID = topicID
        self.include = include
    }

    public var path: String {
        return "\(context.pathComponent)/discussion_topics/\(topicID)"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = []
        if !include.isEmpty {
            query.append(.include(include.map { $0.rawValue }))
        }
        return query
    }
}

struct GetFullTopicRequest: APIRequestable {
    typealias Response = APIDiscussionFullTopic

    let context: Context
    let topicID: String
    let includeNewEntries: Bool

    init(context: Context, topicID: String, includeNewEntries: Bool = true) {
        self.context = context
        self.topicID = topicID
        self.includeNewEntries = includeNewEntries
    }

    public var path: String {
        return "\(context.pathComponent)/discussion_topics/\(topicID)/view"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = []
        if includeNewEntries {
            query.append(.value("include_new_entries", "1"))
        }
        return query
    }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics.index
struct ListDiscussionTopicsRequest: APIRequestable {
    typealias Response = [APIDiscussionTopic]

    let context: Context
    let include: [GetTopicRequest.Include]
    let perPage: Int?

    init(context: Context, perPage: Int? = 100, include: [GetTopicRequest.Include] = GetTopicRequest.defaultIncludes) {
        self.context = context
        self.include = include
        self.perPage = perPage
    }

    public var path: String {
        return "\(context.pathComponent)/discussion_topics"
    }

    public var query: [APIQueryItem] {
        [
            .perPage(perPage),
            .include(include.map { $0.rawValue }),
        ]
    }
}
