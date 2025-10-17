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
