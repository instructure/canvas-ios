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
    case discussionEntry = "DiscussionEntry"
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
    let title: String?
    let message: String?
    let html_url: URL?
    let created_at: Date
    let updated_at: Date
    let type: ActivityType
    let context_type: String?
    let course_id: ID?
    let group_id: ID?
}

#if DEBUG
extension APIActivity {
    public static func make(
        id: ID = "1",
        title: String = "title",
        message: String = "message",
        html_url: URL = URL(string: "/courses/1/assignments/1")!,
        created_at: Date = Clock.now,
        updated_at: Date = Clock.now,
        type: ActivityType = .message,
        context_type: String = ContextType.course.rawValue,
        course_id: ID? = "1",
        group_id: ID? = nil
    ) -> APIActivity {
        return APIActivity(
            id: id,
            title: title,
            message: message,
            html_url: html_url,
            created_at: created_at,
            updated_at: updated_at,
            type: type,
            context_type: context_type,
            course_id: course_id,
            group_id: group_id
        )
    }
}
#endif

public struct GetActivitiesRequest: APIRequestable {
    public typealias Response = [APIActivity]
    let perPage: Int?

    public init(perPage: Int? = nil) {
        self.perPage = perPage
    }

    public var path: String {
        let context = Context(.user, id: "self")
        return "\(context.pathComponent)/activity_stream"
    }

    public var query: [APIQueryItem] {[
        .value("only_active_courses", "true"),
        .perPage(perPage)
    ]}
}
