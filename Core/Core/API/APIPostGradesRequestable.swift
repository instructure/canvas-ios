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

public enum PostGradePolicy: String, CaseIterable {
    case everyone, graded
}

public struct GraphqlBody: Codable, Equatable {
    let query: String
}

protocol GraphqlRequestable: APIRequestable {
    var query: String? { get }
}

extension GraphqlRequestable {
    public var method: APIMethod {
        return .post
    }
    public var path: String {
        return "/api/graphql"
    }

    public var body: GraphqlBody? {
        if let query = query {
            return GraphqlBody(query: query)
        }
        return nil
    }

}

public struct PostAssignmentGrades: GraphqlRequestable {
    public typealias Response = APINoContent

    public let postPolicy: PostGradePolicy
    public let assignmentID: String

    public init(assignmentID: String, postPolicy: PostGradePolicy) {
        self.postPolicy = postPolicy
        self.assignmentID = assignmentID
    }

    public var query: String? {
        return """
        mutation PostAssignmentGrades
            {
                postAssignmentGrades(input: {assignmentId: "\(assignmentID)", gradedOnly: \(postPolicy == .graded)})
                {
                    assignment { id }
                }
            }
        """
    }
}

public struct GetAssignmentPostPolicyInfoRequest: GraphqlRequestable {
    public typealias Response = PostPolicyModel

    public let courseID: String
    public let assignmentID: String

    public init(courseID: String, assignmentID: String) {
        self.courseID = courseID
        self.assignmentID = assignmentID
    }

    public var query: String? {
        return """
        {
            course(id: "\(courseID)") {
                sectionsConnection {
                  nodes {
                    id
                    name
                  }
                }
              }
              assignment(id: "\(assignmentID)") {
                submissionsConnection {
                  nodes {
                    score
                    excused
                    state
                    postedAt
                  }
                }
              }
        }
        """
    }
}

private struct PostPolicyRawServerResponse: Decodable {
    struct Sections: Decodable {
        var nodes: [PostPolicyModel.SectionNode]
    }

    struct PostPolicyData: Decodable {
        var course: Course
        var assignment: Assignment
    }

    struct Course: Decodable {
        var sectionsConnection: Sections
    }

    struct Assignment: Decodable {
        var submissionsConnection: Submissions
    }

    struct Submissions: Decodable {
        var nodes: [PostPolicyModel.SubmissionNode]
    }

    var data: PostPolicyData
}

public struct PostPolicyModel: Codable {
    public var sections: [SectionNode]
    public var submissions: [SubmissionNode]

    public init(from decoder: Decoder) throws {
        let rawResponse = try PostPolicyRawServerResponse(from: decoder)
        sections = rawResponse.data.course.sectionsConnection.nodes
        submissions = rawResponse.data.assignment.submissionsConnection.nodes
    }

    public func encode(to encoder: Encoder) throws {
    }

    public struct SectionNode: Decodable {
        public var id: String
        public var name: String
    }

    public struct SubmissionNode: Decodable {
        public var score: Double?
        public var excused: Bool
        public var state: String
        public var postedAt: Date?
        public var isGraded: Bool {
            return ( score != nil && state == "graded" ) || excused
        }

        public var isHidden: Bool {
            return isGraded && postedAt == nil
        }
    }
}
