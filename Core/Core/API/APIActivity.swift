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

import Foundation

public enum ActivityType: String, Codable {
    case discussion = "DiscussionTopic"
    case announcement = "Announcement"
    case conversation = "Conversation"
    case message = "Message"
    case submission = "Submission"
    case conference = "WebConference"
    case collaboration = "Collaboration"
    case assessmentRequest = "AssessmentRequest"
}

public struct APIActivity: Codable {
    let id: ID
    let title: String
    let message: String
    let html_url: URL
    let created_at: Date
    let updated_at: Date
    let type: ActivityType
    let context_type: String
    let course_id: ID?
    let group_id: ID?
}

public struct GetActivitiesRequest: APIRequestable {
    public typealias Response = [APIActivity]

    public var path: String {
        return "users/self/activity_stream"
    }

    public var query: [APIQueryItem] {
        return [
            .value("per_page", "99"),
        ]
    }
}
