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

public struct APIDiscussionEntry: Codable, Equatable {
    let id: ID
    let user_id: ID?
    let editor_id: ID?
    let parent_id: ID?
    let created_at: Date?
    let updated_at: Date?
    var message: String?
    let rating_sum: Int?
    let replies: [APIDiscussionEntry]?
    let attachment: APIFile?
    let deleted: Bool?
}

#if DEBUG

extension APIDiscussionEntry {
    public static func make(
        id: ID = "1",
        user_id: ID? = "1",
        editor_id: ID? = nil,
        parent_id: ID? = nil,
        created_at: Date? = nil,
        updated_at: Date = Date(timeIntervalSinceReferenceDate: 0),
        message: String = "message",
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
            rating_sum: rating_sum,
            replies: replies,
            attachment: attachment,
            deleted: deleted
        )
    }
}

#endif
