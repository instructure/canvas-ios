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
    public let allow_rating: Bool
    public let anonymous_state: String?
    public let assignment: APIList<APIAssignment>?
    public let assignment_id: ID?
    public let attachments: [APIFile]?
    public let author: APIDiscussionParticipant?
    public let can_unpublish: Bool?
    public let created_at: Date?
    public let context_code: String? // Only populated while using https://canvas.instructure.com/doc/api/announcements.html#method.announcements_api.index
    public let delayed_post_at: Date?
    public let discussion_subentry_count: Int
    public let discussion_type: String?
    public let group_category_id: ID?
    public let group_topic_children: [APIDiscussionTopicChild]?
    public let html_url: URL?
    public let id: ID
    public let is_section_specific: Bool
    public let last_reply_at: Date?
    public var locked: Bool?
    public let locked_for_user: Bool
    public let lock_at: Date?
    public var message: String?
    public let only_graders_can_rate: Bool?
    public let permissions: APIDiscussionPermissions?
    public let pinned: Bool?
    public let position: Int?
    public let posted_at: Date?
    public let published: Bool
    public let require_initial_post: Bool?
    public let sections: [APICourseSection]?
    public let sort_by_rating: Bool
    public let subscribed: Bool?
    public let subscription_hold: String?
    public var title: String?
    public let unread_count: Int?
}

public struct APIDiscussionTopicChild: Codable, Equatable {
    let id: ID
    let group_id: ID
}

public struct APIDiscussionParticipant: Codable, Equatable {
    public let id: ID?
    public let display_name: String?
    public let avatar_image_url: APIURL?
    public let html_url: URL?
    public let pronouns: String?
}

public struct APIDiscussionEntry: Codable, Equatable {
    let id: ID
    let user_id: ID?
    let editor_id: ID?
    let parent_id: ID?
    let created_at: Date?
    let updated_at: Date?
    var message: String?
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
        allow_rating: Bool = false,
        anonymous_state: String? = nil,
        assignment: APIAssignment? = nil,
        assignment_id: ID? = nil,
        attachments: [APIFile]? = nil,
        author: APIDiscussionParticipant = .make(),
        can_unpublish: Bool? = nil,
        created_at: Date? = Clock.now,
        context_code: String? = nil,
        delayed_post_at: Date? = nil,
        discussion_subentry_count: Int = 1,
        discussion_type: String? = "threaded",
        group_category_id: ID? = nil,
        group_topic_children: [APIDiscussionTopicChild]? = nil,
        html_url: URL? = nil,
        id: ID = "1",
        is_section_specific: Bool = false,
        last_reply_at: Date? = nil,
        locked: Bool? = nil,
        locked_for_user: Bool = false,
        lock_at: Date? = nil,
        message: String? = "message",
        only_graders_can_rate: Bool? = nil,
        permissions: APIDiscussionPermissions? = .make(),
        pinned: Bool? = false,
        position: Int? = 1,
        posted_at: Date? = nil,
        published: Bool = true,
        require_initial_post: Bool? = false,
        sections: [APICourseSection]? = nil,
        sort_by_rating: Bool = false,
        subscribed: Bool? = true,
        subscription_hold: String? = nil,
        title: String? = "my discussion topic",
        unread_count: Int? = 0
    ) -> APIDiscussionTopic {
        return APIDiscussionTopic(
            allow_rating: allow_rating,
            anonymous_state: anonymous_state,
            assignment: assignment.map { APIList($0) },
            assignment_id: assignment_id,
            attachments: attachments,
            author: author,
            can_unpublish: can_unpublish,
            created_at: created_at,
            context_code: context_code,
            delayed_post_at: delayed_post_at,
            discussion_subentry_count: discussion_subentry_count,
            discussion_type: discussion_type,
            group_category_id: group_category_id,
            group_topic_children: group_topic_children,
            html_url: html_url,
            id: id,
            is_section_specific: is_section_specific,
            last_reply_at: last_reply_at,
            locked: locked,
            locked_for_user: locked_for_user,
            lock_at: lock_at,
            message: message,
            only_graders_can_rate: only_graders_can_rate,
            permissions: permissions,
            pinned: pinned,
            position: position,
            posted_at: posted_at,
            published: published,
            require_initial_post: require_initial_post,
            sections: sections,
            sort_by_rating: sort_by_rating,
            subscribed: subscribed,
            subscription_hold: subscription_hold,
            title: title,
            unread_count: unread_count
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

    public static func make(from user: APIUser) -> APIDiscussionParticipant {
        APIDiscussionParticipant.make(
            id: user.id,
            display_name: user.name,
            avatar_image_url: user.avatar_url?.rawValue,
            html_url: URL(string: "/users/\(user.id)"),
            pronouns: user.pronouns
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
            .make(id: 2, display_name: "Alice", html_url: URL(string: "/users/2"))
        ],
        unread_entries: [ID] = [1, 3, 5],
        entry_ratings: [String: Int] = ["3": 1, "5": 1],
        forced_entries: [ID] = [1],
        view: [APIDiscussionEntry] = [
            .make(id: 1, message: "m1", rating_sum: 1, replies: [
                .make(id: 2, user_id: 2, parent_id: 1, message: "m2", rating_sum: 0, replies: [
                    .make(id: 3, parent_id: 2, message: "m3", rating_sum: 3, replies: [
                        .make(id: 4, parent_id: 3, message: "m4 (deep)")
                    ])
                ])
            ]),
            .make(id: 5, message: "m5", rating_sum: 1)
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
            rating_sum: rating_sum,
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

    enum DiscussionKey: String {
        case attachment, allow_rating, anonymous_state, delayed_post_at, discussion_type, id, is_announcement, locked, lock_at,
            message, only_graders_can_rate, pinned, published, remove_attachment, require_initial_post,
            sort_by_rating, specific_sections, title
    }

    let context: Context
    let form: APIFormData?
    let method = APIMethod.post
    var path: String { "\(context.pathComponent)/discussion_topics" }

    init(context: Context, form: [DiscussionKey: APIFormDatum?] = [:]) {
        self.context = context
        var formData: APIFormData = []
        for (key, value) in form {
            if let value = value {
                formData.append((key: key.rawValue, value: value))
            }
        }
        self.form = formData
    }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics.update
struct PutDiscussionTopicRequest: APIRequestable {
    typealias Response = APIDiscussionTopic

    typealias DiscussionKey = PostDiscussionTopicRequest.DiscussionKey

    let context: Context
    let topicID: String
    let form: APIFormData?
    let method = APIMethod.put
    var path: String { "\(context.pathComponent)/discussion_topics/\(topicID)" }

    init(context: Context, topicID: String, form: [DiscussionKey: APIFormDatum?] = [:]) {
        self.context = context
        self.topicID = topicID
        var formData: APIFormData = []
        for (key, value) in form {
            if let value = value {
                formData.append((key: key.rawValue, value: value))
            }
        }
        self.form = formData
    }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics.destroy
struct DeleteDiscussionTopicRequest: APIRequestable {
    struct Response: Codable {
        let discussion_topic: DeletedDiscussionTopic
    }
    // The response is missing lots of fields we usually expect,
    // and we are deleting the object so we don't care much about its structure.
    struct DeletedDiscussionTopic: Codable {
        let id: ID
    }

    let context: Context
    let topicID: String
    var method: APIMethod { .delete }
    var path: String { "\(context.pathComponent)/discussion_topics/\(topicID)" }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.subscribe_topic
// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.unsubscribe_topic
struct SubscribeDiscussionTopicRequest: APIRequestable {
    typealias Response = APINoContent

    let context: Context
    let topicID: String
    let method: APIMethod
    var path: String { "\(context.pathComponent)/discussion_topics/\(topicID)/subscribed" }
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
public struct GetDiscussionTopicRequest: APIRequestable {
    public typealias Response = APIDiscussionTopic

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
struct GetDiscussionTopicsRequest: APIRequestable {
    typealias Response = [APIDiscussionTopic]

    let context: Context
    let include: [GetDiscussionTopicRequest.Include]
    let perPage: Int?
    let isAnnouncement: Bool

    init(
        context: Context,
        perPage: Int? = 100,
        include: [GetDiscussionTopicRequest.Include] = GetDiscussionTopicRequest.defaultIncludes,
        isAnnouncement: Bool = false
    ) {
        self.context = context
        self.include = include
        self.perPage = perPage
        self.isAnnouncement = isAnnouncement
    }

    public var path: String { "\(context.pathComponent)/discussion_topics" }

    public var query: [APIQueryItem] { [
        .perPage(perPage),
        .include(include.map { $0.rawValue }),
        .optionalValue("only_announcements", isAnnouncement ? "1" : nil)
    ] }
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

// https://canvas.instructure.com/doc/api/announcements.html#method.announcements_api.index
public struct GetAllAnnouncementsRequest: APIRequestable {
    public typealias Response = [APIDiscussionTopic]
    var contextCodes: [String] = []
    private let activeOnly: Bool?
    private let latestOnly: Bool?

    public init(contextCodes: [String], activeOnly: Bool? = nil, latestOnly: Bool? = nil) {
        self.contextCodes = contextCodes
        self.activeOnly = activeOnly
        self.latestOnly = latestOnly
    }

    public var path = "announcements"
    public var query: [APIQueryItem] {[
        .array("context_codes", contextCodes),
        .optionalBool("active_only", activeOnly),
        .optionalBool("latest_only", latestOnly)
    ]}
}
