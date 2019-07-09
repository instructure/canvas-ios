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
        author: APIDiscussionAuthor = .make()
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
            author: author
        )
    }
}

extension APIDiscussionAuthor {
    public static func make(
        id: ID? = "1",
        display_name: String? = "Bob",
        avatar_image_url: URL? = nil,
        html_url: URL? = URL(string: "/users/1")
    ) -> APIDiscussionAuthor {
        return APIDiscussionAuthor(
            id: id,
            display_name: display_name,
            avatar_image_url: avatar_image_url,
            html_url: html_url
        )
    }
}
