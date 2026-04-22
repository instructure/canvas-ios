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
    struct Variables: Codable, Equatable {}
    typealias Response = GetUnreadAnnouncementsCountResponse

    static let query = """
    query GetUnreadAnnouncementsCount {
      allCourses {
        _id
        discussionsConnection(filter: {isAnnouncement: true}) {
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

    var variables: Variables { Variables() }
}

struct GetUnreadAnnouncementsCountResponse: Codable {
    let data: ResponseData

    struct ResponseData: Codable {
        let allCourses: [CourseData]
    }

    struct CourseData: Codable {
        let _id: String
        let discussionsConnection: DiscussionsConnection

        var unreadAnnouncementCount: Int {
            unreadNodes.count
        }

        var singleUnreadAnnouncementId: String? {
            unreadNodes.count == 1 ? unreadNodes.first?._id : nil
        }

        private var unreadNodes: [DiscussionNode] {
            discussionsConnection.nodes.filter { $0.participant?.read == false }
        }
    }

    struct DiscussionsConnection: Codable {
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
