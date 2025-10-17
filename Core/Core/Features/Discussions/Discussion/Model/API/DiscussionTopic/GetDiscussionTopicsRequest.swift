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
