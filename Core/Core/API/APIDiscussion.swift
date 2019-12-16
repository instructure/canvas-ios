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
    let attachments: [APIFile]?
    let author: APIDiscussionParticipant
    let permissions: APIDiscussionPermissions?
    let allow_rating: Bool
    let sort_by_rating: Bool
}

public struct APIDiscussionParticipant: Codable, Equatable {
    let id: ID?
    let display_name: String?
    let avatar_image_url: URL?
    let html_url: URL?
}

public struct APIDiscussionEntry: Codable, Equatable {
    let id: ID
    let user_id: ID
    let parent_id: ID?
    let created_at: Date?
    let updated_at: Date?
    let message: String
    let rating_count: Int
    let rating_sum: Int
    let replies: [APIDiscussionEntry]?
}

public struct APIDiscussionPermissions: Codable, Equatable {
    let attach: Bool?
}

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.view
public struct APIDiscussionFullTopic: Codable, Equatable {
    let participants: [APIDiscussionParticipant]
    let unread_entries: [ID]
    let entry_ratings: [String: Int]
    let forced_entries: [ID]
    let view: [APIDiscussionEntry]
}
