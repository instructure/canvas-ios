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

// https://canvas.instructure.com/doc/api/discussion_topics.html#DiscussionTopic
public struct APIDiscussionTopic: Codable, Equatable {
    let id: ID
    let assignment_id: ID?
    let title: String?
    let message: String?
    let html_url: URL?
    let posted_at: Date?
    let last_reply_at: Date?
    let discussion_subentry_count: Int
    let published: Bool
    let attachments: [APIFile]?
    let author: APIDiscussionParticipant
    let permissions: APIDiscussionPermissions?
    let allow_rating: Bool
    let sort_by_rating: Bool
    let only_graders_can_rate: Bool?
    let locked_for_user: Bool
    let group_category_id: ID?
    let group_topic_children: [APIDiscussionTopicChild]?
    let subscription_hold: String?
    let is_section_specific: Bool
    let sections: [APICourseSection]?
}

public struct APIDiscussionTopicChild: Codable, Equatable {
    let id: ID
    let group_id: ID
}

public struct APIDiscussionParticipant: Codable, Equatable {
    let id: ID?
    let display_name: String?
    let avatar_image_url: APIURL?
    let html_url: URL?
    let pronouns: String?
}

public struct APIDiscussionEntry: Codable, Equatable {
    let id: ID
    let user_id: ID?
    let editor_id: ID?
    let parent_id: ID?
    let created_at: Date?
    let updated_at: Date?
    let message: String?
    let rating_count: Int?
    let rating_sum: Int?
    let replies: [APIDiscussionEntry]?
    let attachment: APIFile?
    let deleted: Bool?
}

public struct APIDiscussionPermissions: Codable, Equatable {
    let attach: Bool?
    let update: Bool?
    let reply: Bool?
    let delete: Bool?
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.view
public struct APIDiscussionView: Codable, Equatable {
    let participants: [APIDiscussionParticipant]
    let unread_entries: [ID]
    var entry_ratings: [String: Int]
    let forced_entries: [ID]
    let view: [APIDiscussionEntry]
    let new_entries: [APIDiscussionEntry]?
}

#if DEBUG
extension APIDiscussionTopic {
    public static func make(
        id: ID = "1",
        assignment_id: ID? = nil,
        title: String? = "my discussion topic",
        message: String? = "message",
        html_url: URL? = nil,
        posted_at: Date? = nil,
        last_reply_at: Date? = nil,
        discussion_subentry_count: Int = 1,
        published: Bool = true,
        attachments: [APIFile]? = nil,
        author: APIDiscussionParticipant = .make(),
        permissions: APIDiscussionPermissions? = .make(),
        allow_rating: Bool = false,
        sort_by_rating: Bool = false,
        only_graders_can_rate: Bool? = nil,
        locked_for_user: Bool = false,
        group_category_id: ID? = nil,
        group_topic_children: [APIDiscussionTopicChild]? = nil,
        subscription_hold: String? = nil,
        is_section_specific: Bool = false,
        sections: [APICourseSection]? = nil
    ) -> APIDiscussionTopic {
        return APIDiscussionTopic(
            id: id,
            assignment_id: assignment_id,
            title: title,
            message: message,
            html_url: html_url,
            posted_at: posted_at,
            last_reply_at: last_reply_at,
            discussion_subentry_count: discussion_subentry_count,
            published: published,
            attachments: attachments,
            author: author,
            permissions: permissions,
            allow_rating: allow_rating,
            sort_by_rating: sort_by_rating,
            only_graders_can_rate: only_graders_can_rate,
            locked_for_user: locked_for_user,
            group_category_id: group_category_id,
            group_topic_children: group_topic_children,
            subscription_hold: subscription_hold,
            is_section_specific: is_section_specific,
            sections: sections
        )
    }
}

extension APIDiscussionParticipant {
    public static func make(
        id: ID? = "1",
        display_name: String? = "Bob",
        avatar_image_url: URL? = nil,
        html_url: URL? = URL(string: "/users/1"),
        pronouns: String? = nil
    ) -> APIDiscussionParticipant {
        return APIDiscussionParticipant(
            id: id,
            display_name: display_name,
            avatar_image_url: APIURL(rawValue: avatar_image_url),
            html_url: html_url,
            pronouns: pronouns
        )
    }
}

extension APIDiscussionPermissions {
    public static func make(
        attach: Bool? = nil,
        update: Bool? = nil,
        reply: Bool? = nil,
        delete: Bool? = nil
    ) -> APIDiscussionPermissions {
        return APIDiscussionPermissions(
            attach: attach,
            update: update,
            reply: reply,
            delete: delete
        )
    }
}

extension APIDiscussionTopicChild {
    public static func make(id: String = "1", group_id: String = "2") -> APIDiscussionTopicChild {
        return APIDiscussionTopicChild(id: ID(id), group_id: ID(group_id))
    }
}

extension APIDiscussionView {
    public static func make(
        participants: [APIDiscussionParticipant] = [
            .make(),
            .make(id: 2, display_name: "Alice", html_url: URL(string: "/users/2")),
        ],
        unread_entries: [ID] = [1, 3, 5],
        entry_ratings: [String: Int] = ["3": 1, "5": 1],
        forced_entries: [ID] = [1],
        view: [APIDiscussionEntry] = [
            .make(id: 1, message: "m1", rating_count: 1, replies: [
                .make(id: 2, user_id: 2, parent_id: 1, message: "m2", rating_count: 0, replies: [
                    .make(id: 3, parent_id: 2, message: "m3", rating_count: 3, replies: [
                        .make(id: 4, parent_id: 3, message: "m4 (deep)"),
                    ]),
                ]),
            ]),
            .make(id: 5, message: "m5", rating_count: 1),
        ],
        new_entries: [APIDiscussionEntry]? = nil
    ) -> APIDiscussionView {
        return APIDiscussionView(
            participants: participants,
            unread_entries: unread_entries,
            entry_ratings: entry_ratings,
            forced_entries: forced_entries,
            view: view,
            new_entries: new_entries
        )
    }
}
extension APIDiscussionEntry {
    public static func make(
        id: ID = "1",
        user_id: ID? = "1",
        editor_id: ID? = nil,
        parent_id: ID? = nil,
        created_at: Date? = nil,
        updated_at: Date = Date(timeIntervalSinceReferenceDate: 0),
        message: String = "message",
        rating_count: Int? = nil,
        rating_sum: Int? = nil,
        replies: [APIDiscussionEntry]? = nil,
        attachment: APIFile? = nil,
        deleted: Bool? = nil
    ) -> APIDiscussionEntry {
        return APIDiscussionEntry(
            id: id,
            user_id: user_id,
            editor_id: editor_id,
            parent_id: parent_id,
            created_at: created_at,
            updated_at: updated_at,
            message: message,
            rating_count: rating_count,
            rating_sum: rating_sum ?? rating_count,
            replies: replies,
            attachment: attachment,
            deleted: deleted
        )
    }
}
#endif

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
        "\(context.pathComponent)/discussion_topics"
    }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics.destroy
struct DeleteDiscussionTopicRequest: APIRequestable {
    typealias Response = APIDiscussionTopic

    let context: Context
    let topicID: String
    let method = APIMethod.delete
    var path: String { "\(context.pathComponent)/discussion_topics/\(topicID)" }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.add_entry
// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.add_reply
struct PostDiscussionEntryRequest: APIRequestable {
    typealias Response = APIDiscussionEntry

    let context: Context
    let topicID: String
    let form: APIFormData?
    let method = APIMethod.post
    let replyId: String?

    init(context: Context, topicID: String, entryID: String? = nil, message: String, attachment: URL? = nil) {
        self.context = context
        self.topicID = topicID
        self.replyId = entryID
        var form: APIFormData = [ (key: "message", value: .string(message)) ]
        if let url = attachment {
            form.append((key: "attachment", value: .file(
                filename: url.lastPathComponent,
                type: "application/octet-stream",
                at: url
            )))
        }
        self.form = form
    }

    public var path: String {
        var path = "\(context.pathComponent)/discussion_topics/\(topicID)/entries"
        if let replyId = replyId {
            path.append("/\(replyId)/replies")
        }
        return path
    }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_entries.update
struct PutDiscussionEntryRequest: APIRequestable {
    typealias Response = APIDiscussionEntry
    struct Body: Codable {
        let message: String
    }

    let body: Body?
    let method = APIMethod.put
    let path: String

    init(context: Context, topicID: String, entryID: String, message: String) {
        path = "\(context.pathComponent)/discussion_topics/\(topicID)/entries/\(entryID)"
        body = Body(message: message)
    }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.entries
struct ListDiscussionEntriesRequest: APIRequestable {
    typealias Response = [APIDiscussionEntry]
    let context: Context
    let topicID: String
    public var path: String {
        "\(context.pathComponent)/discussion_topics/\(topicID)/entries"
    }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.show
struct GetDiscussionTopicRequest: APIRequestable {
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
        "\(context.pathComponent)/discussion_topics/\(topicID)"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = []
        if !include.isEmpty {
            query.append(.include(include.map { $0.rawValue }))
        }
        return query
    }
}

struct GetDiscussionViewRequest: APIRequestable {
    typealias Response = APIDiscussionView

    let context: Context
    let topicID: String
    let includeNewEntries: Bool

    init(context: Context, topicID: String, includeNewEntries: Bool = true) {
        self.context = context
        self.topicID = topicID
        self.includeNewEntries = includeNewEntries
    }

    public var path: String {
        "\(context.pathComponent)/discussion_topics/\(topicID)/view"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = []
        if includeNewEntries {
            query.append(.bool("include_new_entries", true))
        }
        return query
    }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics.index
struct ListDiscussionTopicsRequest: APIRequestable {
    typealias Response = [APIDiscussionTopic]

    let context: Context
    let include: [GetDiscussionTopicRequest.Include]
    let perPage: Int?

    init(context: Context, perPage: Int? = 100, include: [GetDiscussionTopicRequest.Include] = GetDiscussionTopicRequest.defaultIncludes) {
        self.context = context
        self.include = include
        self.perPage = perPage
    }

    public var path: String {
        "\(context.pathComponent)/discussion_topics"
    }

    public var query: [APIQueryItem] {
        [
            .perPage(perPage),
            .include(include.map { $0.rawValue }),
        ]
    }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.mark_topic_read
// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.mark_topic_unread
struct MarkDiscussionTopicReadRequest: APIRequestable {
    typealias Response = APINoContent

    let context: Context
    let topicID: String
    let isRead: Bool

    var method: APIMethod { isRead ? .put : .delete }
    var path: String { "\(context.pathComponent)/discussion_topics/\(topicID)/read" }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.mark_all_read
// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.mark_all_unread
struct MarkDiscussionEntriesReadRequest: APIRequestable {
    typealias Response = APINoContent

    let context: Context
    let topicID: String
    let isRead: Bool
    let isForcedRead: Bool

    var method: APIMethod { isRead ? .put : .delete }
    var path: String { "\(context.pathComponent)/discussion_topics/\(topicID)/read_all" }
    var query: [APIQueryItem] { [ .bool("forced_read_state", isForcedRead) ] }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.mark_entry_read
// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.mark_entry_unread
struct MarkDiscussionEntryReadRequest: APIRequestable {
    typealias Response = APINoContent

    let context: Context
    let topicID: String
    let entryID: String
    let isRead: Bool
    let isForcedRead: Bool

    var method: APIMethod { isRead ? .put : .delete }
    var path: String { "\(context.pathComponent)/discussion_topics/\(topicID)/entries/\(entryID)/read" }
    var query: [APIQueryItem] { [ .bool("forced_read_state", isForcedRead) ] }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.rate_entry
struct PostDiscussionEntryRatingRequest: APIRequestable {
    typealias Response = APINoContent

    let context: Context
    let topicID: String
    let entryID: String
    let isLiked: Bool

    var method: APIMethod { .post }
    var path: String { "\(context.pathComponent)/discussion_topics/\(topicID)/entries/\(entryID)/rating" }
    var body: [String: UInt]? { [ "rating": isLiked ? 1 : 0 ] }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_entries.destroy
struct DeleteDiscussionEntryRequest: APIRequestable {
    typealias Response = APINoContent

    let context: Context
    let topicID: String
    let entryID: String
    var method: APIMethod { .delete }
    var path: String { "\(context.pathComponent)/discussion_topics/\(topicID)/entries/\(entryID)" }
}
