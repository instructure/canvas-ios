//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

// https://canvas.instructure.com/doc/api/discussion_topics.html#DiscussionTopic
public struct APIDiscussionTopic: Codable, Equatable {
    let id: ID
    let assignment_id: ID?
    let title: String?
    let message: String?
    let html_url: URL?
    let posted_at: Date?
    let last_reply_at: Date?
    let discussion_subentry_count: Int
    let published: Bool
}

public struct APIDiscussionEntry: Codable, Equatable {
    let id: ID
    let user_id: ID
    let parent_id: ID?
    let created_at: Date?
    let updated_at: Date?
    let message: String
}
