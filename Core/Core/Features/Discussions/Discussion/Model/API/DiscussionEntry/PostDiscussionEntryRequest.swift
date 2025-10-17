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
