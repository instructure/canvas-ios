//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import Foundation

struct GetUnreadAnnouncementsCountRequest: APIGraphQLRequestable {
    private static let pageSize = 20

    struct Variables: Codable, Equatable {
        let pageSize: Int
        let cursor: String?
    }
    typealias Response = GetUnreadAnnouncementsCountResponse

    let cursor: String?

    init(cursor: String? = nil) {
        self.cursor = cursor
    }

    static let query = """
    query GetUnreadAnnouncementsCount($pageSize: Int!, $cursor: String) {
      allCourses {
        _id
        discussionsConnection(filter: {isAnnouncement: true}, first: $pageSize, after: $cursor) {
          pageInfo {
            endCursor
            hasNextPage
          }
          nodes {
            _id
            participant {
              read
            }
          }
        }
      }
    }
    """

    var variables: Variables { Variables(pageSize: Self.pageSize, cursor: cursor) }
}

struct GetUnreadAnnouncementsCountResponse: Codable {
    let data: ResponseData

    struct ResponseData: Codable {
        let allCourses: [CourseData]
    }

    struct CourseData: Codable {
        let _id: String
        let discussionsConnection: DiscussionsConnection

        var unreadAnnouncementIds: [String] { unreadNodes.map { $0._id } }
        var unreadAnnouncementCount: Int { unreadNodes.count }

        private var unreadNodes: [DiscussionNode] {
            discussionsConnection.nodes.filter { $0.participant?.read == false }
        }
    }

    struct DiscussionsConnection: Codable {
        let pageInfo: APIPageInfo?
        let nodes: [DiscussionNode]
    }

    struct DiscussionNode: Codable {
        let _id: String
        let participant: Participant?
    }

    struct Participant: Codable {
        let read: Bool
    }
}

#if DEBUG

extension GetUnreadAnnouncementsCountResponse {
    static func make(courses: [CourseData] = []) -> GetUnreadAnnouncementsCountResponse {
        .init(data: .init(allCourses: courses))
    }
}

extension GetUnreadAnnouncementsCountResponse.CourseData {
    static func make(
        id: String = "some id",
        nodes: [GetUnreadAnnouncementsCountResponse.DiscussionNode] = [],
        hasNextPage: Bool = false,
        endCursor: String? = nil
    ) -> GetUnreadAnnouncementsCountResponse.CourseData {
        .init(_id: id, discussionsConnection: .init(
            pageInfo: .make(endCursor: endCursor, hasNextPage: hasNextPage),
            nodes: nodes
        ))
    }
}

extension GetUnreadAnnouncementsCountResponse.DiscussionNode {
    static func make(id: String = "some id", read: Bool = true) -> GetUnreadAnnouncementsCountResponse.DiscussionNode {
        .init(_id: id, participant: .init(read: read))
    }
}

#endif
