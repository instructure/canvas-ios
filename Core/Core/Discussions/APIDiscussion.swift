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
    let allow_rating: Bool
    let assignment_id: ID?
    let attachments: [APIFile]?
    let author: APIDiscussionParticipant
    let can_unpublish: Bool?
    let delayed_post_at: Date?
    let discussion_subentry_count: Int
    let discussion_type: String?
    let group_category_id: ID?
    let group_topic_children: [APIDiscussionTopicChild]?
    let html_url: URL?
    let id: ID
    let is_section_specific: Bool
    let last_reply_at: Date?
    var locked: Bool?
    let locked_for_user: Bool
    let lock_at: Date?
    var message: String?
    let only_graders_can_rate: Bool?
    let permissions: APIDiscussionPermissions?
    let posted_at: Date?
    let published: Bool
    let require_initial_post: Bool?
    let sections: [APICourseSection]?
    let sort_by_rating: Bool
    let subscribed: Bool?
    let subscription_hold: String?
    var title: String?
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
    var message: String?
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
        allow_rating: Bool = false,
        assignment_id: ID? = nil,
        attachments: [APIFile]? = nil,
        author: APIDiscussionParticipant = .make(),
        can_unpublish: Bool? = nil,
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
        posted_at: Date? = nil,
        published: Bool = true,
        require_initial_post: Bool? = false,
        sections: [APICourseSection]? = nil,
        sort_by_rating: Bool = false,
        subscribed: Bool? = true,
        subscription_hold: String? = nil,
        title: String? = "my discussion topic"
    ) -> APIDiscussionTopic {
        return APIDiscussionTopic(
            allow_rating: allow_rating,
            assignment_id: assignment_id,
            attachments: attachments,
            author: author,
            can_unpublish: can_unpublish,
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
            posted_at: posted_at,
            published: published,
            require_initial_post: require_initial_post,
            sections: sections,
            sort_by_rating: sort_by_rating,
            subscribed: subscribed,
            subscription_hold: subscription_hold,
            title: title
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

    let context: Context
    let form: APIFormData?
    let method = APIMethod.post
    var path: String { "\(context.pathComponent)/discussion_topics" }

    // swiftlint:disable:next function_parameter_count
    init(
        context: Context,
        allowRating: Bool,
        attachment: URL?,
        delayedPostAt: Date?,
        discussionType: String,
        isAnnouncement: Bool,
        lockAt: Date?,
        locked: Bool? = nil,
        message: String,
        onlyGradersCanRate: Bool,
        published: Bool?,
        requireInitialPost: Bool?,
        sections: [String] = [],
        sortByRating: Bool,
        title: String
    ) {
        self.context = context
        var form: APIFormData = [
            (key: "allow_rating", value: .bool(allowRating)),
            (key: "delayed_post_at", value: .date(delayedPostAt)),
            (key: "discussion_type", value: .string(discussionType)),
            (key: "is_announcement", value: .bool(isAnnouncement)),
            (key: "lock_at", value: .date(lockAt)),
            (key: "message", value: .string(message)),
            (key: "only_graders_can_rate", value: .bool(onlyGradersCanRate)),
            (key: "sort_by_rating", value: .bool(sortByRating)),
            (key: "specific_sections", value: .string(sections.isEmpty ? "all" : sections.joined(separator: ","))),
            (key: "title", value: .string(title)),
        ]
        if let url = attachment {
            form.append((key: "attachment", value: .file(
                filename: url.lastPathComponent,
                type: "application/octet-stream",
                at: url
            )))
        }
        if let locked = locked {
            form.append((key: "locked", value: .bool(locked)))
        }
        if let published = published {
            form.append((key: "published", value: .bool(published)))
        }
        if let requireInitialPost = requireInitialPost {
            form.append((key: "require_initial_post", value: .bool(requireInitialPost)))
        }
        self.form = form
    }
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics.update
struct PutDiscussionTopicRequest: APIRequestable {
    typealias Response = APIDiscussionTopic

    let context: Context
    let topicID: String
    let form: APIFormData?
    let method = APIMethod.put
    var path: String { "\(context.pathComponent)/discussion_topics/\(topicID)" }

    // swiftlint:disable:next function_parameter_count
    init(
        context: Context,
        topicID: String,
        allowRating: Bool,
        attachment: URL?,
        delayedPostAt: Date?,
        discussionType: String,
        lockAt: Date?,
        locked: Bool? = nil,
        message: String,
        onlyGradersCanRate: Bool,
        published: Bool?,
        removeAttachment: Bool?,
        requireInitialPost: Bool?,
        sections: [String] = [],
        sortByRating: Bool,
        title: String
    ) {
        self.context = context
        self.topicID = topicID
        var form: APIFormData = [
            (key: "allow_rating", value: .bool(allowRating)),
            (key: "delayed_post_at", value: .date(delayedPostAt)),
            (key: "discussion_type", value: .string(discussionType)),
            (key: "id", value: .string(topicID)),
            (key: "lock_at", value: .date(lockAt)),
            (key: "message", value: .string(message)),
            (key: "only_graders_can_rate", value: .bool(onlyGradersCanRate)),
            (key: "sort_by_rating", value: .bool(sortByRating)),
            (key: "specific_sections", value: .string(sections.isEmpty ? "all" : sections.joined(separator: ","))),
            (key: "title", value: .string(title)),
        ]
        if let url = attachment {
            form.append((key: "attachment", value: .file(
                filename: url.lastPathComponent,
                type: "application/octet-stream",
                at: url
            )))
        }
        if let locked = locked {
            form.append((key: "locked", value: .bool(locked)))
        }
        if let published = published {
            form.append((key: "published", value: .bool(published)))
        }
        if let removeAttachment = removeAttachment {
            form.append((key: "remove_attachment", value: .bool(removeAttachment)))
        }
        if let requireInitialPost = requireInitialPost {
            form.append((key: "require_initial_post", value: .bool(requireInitialPost)))
        }
        self.form = form
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
    let method = APIMethod.delete
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
