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
