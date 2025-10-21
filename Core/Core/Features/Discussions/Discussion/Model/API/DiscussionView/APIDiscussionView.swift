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

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.view
public struct APIDiscussionView: Codable, Equatable {
    let participants: [APIDiscussionParticipant]
    let unread_entries: [ID]
    var entry_ratings: [String: Int]
    let forced_entries: [ID]
    let view: [APIDiscussionEntry]
    let new_entries: [APIDiscussionEntry]?
}

#if DEBUG

extension APIDiscussionView {
    public static func make(
        participants: [APIDiscussionParticipant] = [
            .make(),
            .make(id: 2, display_name: "Alice", html_url: URL(string: "/users/2"))
        ],
        unread_entries: [ID] = [1, 3, 5],
        entry_ratings: [String: Int] = ["3": 1, "5": 1],
        forced_entries: [ID] = [1],
        view: [APIDiscussionEntry] = [
            .make(id: 1, message: "m1", rating_sum: 1, replies: [
                .make(id: 2, user_id: 2, parent_id: 1, message: "m2", rating_sum: 0, replies: [
                    .make(id: 3, parent_id: 2, message: "m3", rating_sum: 3, replies: [
                        .make(id: 4, parent_id: 3, message: "m4 (deep)")
                    ])
                ])
            ]),
            .make(id: 5, message: "m5", rating_sum: 1)
        ],
        new_entries: [APIDiscussionEntry]? = nil
    ) -> APIDiscussionView {
        return APIDiscussionView(
            participants: participants,
            unread_entries: unread_entries,
            entry_ratings: entry_ratings,
            forced_entries: forced_entries,
            view: view,
            new_entries: new_entries
        )
    }
}

#endif
