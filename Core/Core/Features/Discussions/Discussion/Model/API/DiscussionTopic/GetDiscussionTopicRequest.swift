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

// https://canvas.instructure.com/doc/api/discussion_topics.html#method.discussion_topics_api.show
public struct GetDiscussionTopicRequest: APIRequestable {
    public typealias Response = APIDiscussionTopic

    public enum Include: String, CaseIterable {
        case allDates = "all_dates"
        case sections
        case sectionsUserCount = "section_user_count"
        case overrides
    }

    let context: Context
    let topicID: String
    public static let defaultIncludes = [ Include.sections ]
    let include: [Include]

    init(context: Context, topicID: String, include: [Include] = defaultIncludes) {
        self.context = context
        self.topicID = topicID
        self.include = include
    }

    public var path: String {
        "\(context.pathComponent)/discussion_topics/\(topicID)"
    }

    public var query: [APIQueryItem] {
        var query: [APIQueryItem] = []
        if !include.isEmpty {
            query.append(.include(include.map { $0.rawValue }))
        }
        return query
    }
}
