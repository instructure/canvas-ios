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

public enum AssignmentFilter: Equatable {
    case allGradingPeriods
    case gradingPeriod(id: String)
}

extension AssignmentFilter: Codable {
    //  `filter: {gradingPeriodId: null}` - will return all assignments regardless of grading period
    //  `filter: {gradingPeriodId: "<id>"}` - will return all assignments in grading period
    typealias CodingRepresentation = [String: String?]

    public init(from decoder: Decoder) throws {
        let representation = try CodingRepresentation(from: decoder)
        if let index = representation.index(forKey: "gradingPeriodId"), let id = representation[index].value {
            self = .gradingPeriod(id: id)
        } else {
            self = .allGradingPeriods
        }
    }

    public func encode(to encoder: Encoder) throws {
        let representation: CodingRepresentation
        switch self {
        case .allGradingPeriods:
            representation = ["gradingPeriodId": nil]
        case .gradingPeriod(let id):
            representation = ["gradingPeriodId": id]
        }
        try representation.encode(to: encoder)
    }
}

public struct AssignmentListRequestable: APIGraphQLRequestable {
    public typealias Response = APIAssignmentListResponse

    public struct Variables: Codable, Equatable {
        public let courseID: String
        public let filter: AssignmentFilter
        public let cursor: String?
        public let pageSize: Int
    }
    public let variables: Variables

    public init(courseID: String, filter: AssignmentFilter, pageSize: Int = 10, cursor: String? = nil) {
        variables = Variables(courseID: courseID, filter: filter, cursor: cursor, pageSize: pageSize)
    }

    static let operationName = "AssignmentList"
    static let query = """
        query \(operationName)($courseID: ID!, $pageSize: Int!, $cursor: String, $filter: AssignmentFilter!) {
          course(id: $courseID) {
            name
            groups: assignmentGroupsConnection {
              nodes {
                id: _id
                name
                assignmentNodes: assignmentsConnection(first: $pageSize, after: $cursor, filter: $filter) {
                  nodes {
                    id: _id
                    name
                    inClosedGradingPeriod
                    htmlUrl
                    submissionTypes
                    quiz {
                      id: _id
                    }
                    lockAt
                    dueAt
                  }
                  pageInfo {
                    endCursor
                    hasNextPage
                  }
                }
              }
            }
          }
        }
        """
}

public struct APIAssignmentListResponse: Codable, Equatable {
    let data: APIAssignmentListResponse.Data

    public var groups: [APIAssignmentListGroup] {
        return data.course.groups.nodes
    }

    struct Data: Codable, Equatable {
        let course: Course
    }

    struct Course: Codable, Equatable {
        let groups: GroupNodes
    }

    struct GroupNodes: Codable, Equatable {
        let nodes: [APIAssignmentListGroup]
    }
}

public struct APIAssignmentListGroup: Codable, Equatable, Hashable {
    public let id: ID
    public let name: String
    let assignmentNodes: Nodes

    public static func == (lhs: APIAssignmentListGroup, rhs: APIAssignmentListGroup) -> Bool {
        return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public var pageInfo: APIPageInfo? {
        return assignmentNodes.pageInfo
    }

    public var assignments: [APIAssignmentListAssignment] {
        return assignmentNodes.nodes
    }

    struct Nodes: Codable, Equatable {
        let nodes: [APIAssignmentListAssignment]
        let pageInfo: APIPageInfo?
    }
}

public struct APIPageInfo: Codable, Equatable {
    public let endCursor: String?
    public let hasNextPage: Bool
}

public struct APIAssignmentListAssignment: Codable, Equatable, Hashable {
    public let id: ID
    public let name: String
    public let inClosedGradingPeriod: Bool
    public let dueAt: Date?
    public let lockAt: Date?
    public let unlockAt: Date?
    public let htmlUrl: String?
    public let submissionTypes: [SubmissionType]
    public var quizID: ID? {
        return quiz?.id
    }
    let quiz: Quiz?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: APIAssignmentListAssignment, rhs: APIAssignmentListAssignment) -> Bool {
        return lhs.id == rhs.id
    }

    struct Quiz: Codable, Equatable {
        let id: ID
    }
}

extension APIAssignmentListAssignment {
    public var formattedDueDate: String? {
        if let lockAt = lockAt, Clock.now > lockAt {
            return NSLocalizedString("Availability: Closed", bundle: .core, comment: "")
        }

        if let lockAt = lockAt, Clock.now > lockAt {
            return NSLocalizedString("Closed", bundle: .core, comment: "")
        }

        if let dueAt = dueAt {
            let dtString = DateFormatter.localizedString(from: dueAt, dateStyle: .medium, timeStyle: .short)
            let format = NSLocalizedString("Due %@", bundle: .core, comment: "i.e. Due <Jan 10, 2020 at 9:00 PM>")
            return String.localizedStringWithFormat(format, dtString)
        }

        return NSLocalizedString("No Due Date", bundle: .core, comment: "")
    }

    public var icon: UIImage? {
        var image: UIImage? = .icon(.assignment, .line)
        if quizID != nil {
            image = .icon(.quiz, .line)
        } else if submissionTypes.contains(.discussion_topic) {
            image = .icon(.discussion, .line)
        } else if submissionTypes.contains(.external_tool) || submissionTypes.contains(.basic_lti_launch) {
            image = .icon(.lti, .line)
        } else if submissionTypes.contains(.wiki_page) {
            image = .icon(.document, .line)
        }

        if let lockAt = lockAt, Clock.now > lockAt {
            image = .icon(.lock, .line)
        }

        return image
    }
}

#if DEBUG
extension APIAssignmentListResponse {
    static func make(
        groups: [APIAssignmentListGroup]
    ) -> APIAssignmentListResponse {
        .init(data: .init(course: .init(groups: .init(nodes: groups))))
    }
}
#endif
