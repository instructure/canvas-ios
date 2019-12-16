//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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
@testable import Core

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
        permissions: APIDiscussionPermissions? = nil,
        allow_rating: Bool = false,
        sort_by_rating: Bool = false
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
            sort_by_rating: sort_by_rating
        )
    }
}

extension APIDiscussionParticipant {
    public static func make(
        id: ID? = "1",
        display_name: String? = "Bob",
        avatar_image_url: URL? = nil,
        html_url: URL? = URL(string: "/users/1")
    ) -> APIDiscussionParticipant {
        return APIDiscussionParticipant(
                id: id,
                display_name: display_name,
                avatar_image_url: avatar_image_url,
                html_url: html_url
        )
    }
}

extension APIDiscussionPermissions {
    public static func make(attach: Bool? = nil) -> APIDiscussionPermissions {
        return APIDiscussionPermissions(attach: attach)
    }
}

extension APIDiscussionFullTopic {
    public static let date1 = Date(timeIntervalSince1970: 0)
    public static func make(
        participants: [APIDiscussionParticipant] = [
            .make(),
            .make(id: 2, display_name: "Alice", html_url: URL(string: "/users/2")),
        ],
        unread_entries: [ID] = [1, 3, 5],
        entry_ratings: [String: Int] = ["3": 1, "5": 1],
        forced_entries: [ID] = [1],
        view: [APIDiscussionEntry] = [
            .make(id: 1, updated_at: date1, message: "m1", rating_count: 1, replies: [
                .make(id: 2, user_id: 2, updated_at: date1, message: "m2", replies: [
                    .make(id: 3, updated_at: date1, message: "m3", rating_count: 3, replies: [
                        .make(id: 4, updated_at: date1, message: "m4 (deep)"),
                    ]),
                ]),
            ]),
            .make(id: 5, updated_at: date1, message: "m5", rating_count: 1),
        ]
    ) -> APIDiscussionFullTopic {
        return APIDiscussionFullTopic(
                participants: participants,
                unread_entries: unread_entries,
                entry_ratings: entry_ratings,
                forced_entries: forced_entries,
                view: view
        )
    }
}
