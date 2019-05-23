//
// Copyright (C) 2019-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
