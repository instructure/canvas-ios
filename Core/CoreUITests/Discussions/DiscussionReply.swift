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

import XCTest
import TestsFoundation

enum DiscussionReply: String, ElementWrapper {
    case topReplyButton = "discussion-reply"
    case moreReplies = "discussion.more-replies"
    case replyDone = "edit-discussion-reply.done-btn"
    var id: String { return self.rawValue }
}

extension DiscussionReply {
    static func replyUnread(id: String) -> Element {
        return app.find(id: "reply.\(id).unread")
    }

    static func replyButton(id: String) -> Element {
        return app.find(id: "discussion.reply-btn.\(id)")
    }
}
