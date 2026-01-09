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
    public let context_code: String?
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
    public let read_state: String?
    public let is_checkpointed: Bool?
    public let reply_to_entry_required_count: Int?
    public let has_sub_assignments: Bool?
    public let checkpoints: [APIAssignmentCheckpoint]?
}

extension APIDiscussionTopic {
    public struct APIDiscussionTopicChild: Codable, Equatable {
        let id: ID
        let group_id: ID
    }

    public struct APIDiscussionPermissions: Codable, Equatable {
        let attach: Bool?
        let update: Bool?
        let reply: Bool?
        let delete: Bool?
    }
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
        unread_count: Int? = 0,
        is_checkpointed: Bool? = nil,
        reply_to_entry_required_count: Int? = nil,
        has_sub_assignments: Bool? = nil,
        read_state: String? = "unread",
        checkpoints: [APIAssignmentCheckpoint]? = nil
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
            unread_count: unread_count,
            read_state: read_state,
            is_checkpointed: is_checkpointed,
            reply_to_entry_required_count: reply_to_entry_required_count,
            has_sub_assignments: has_sub_assignments,
            checkpoints: checkpoints
        )
    }
}

extension APIDiscussionTopic.APIDiscussionPermissions {
    public static func make(
        attach: Bool? = nil,
        update: Bool? = nil,
        reply: Bool? = nil,
        delete: Bool? = nil
    ) -> APIDiscussionTopic.APIDiscussionPermissions {
        return APIDiscussionTopic.APIDiscussionPermissions(
            attach: attach,
            update: update,
            reply: reply,
            delete: delete
        )
    }
}

extension APIDiscussionTopic.APIDiscussionTopicChild {
    public static func make(id: String = "1", group_id: String = "2") -> APIDiscussionTopic.APIDiscussionTopicChild {
        return APIDiscussionTopic.APIDiscussionTopicChild(id: ID(id), group_id: ID(group_id))
    }
}

#endif
