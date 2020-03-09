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

public class PostAssignmentGradesPostPolicyRequest: APIGraphQLRequestable {
    public typealias Response = APINoContent
    public struct Input: Codable, Equatable {
        let gradedOnly: Bool
        let assignmentId: String
        let sectionIds: [String]?
    }
    public struct Variables: Codable, Equatable {
        let input: Input
    }
    public let variables: Variables

    init(input: Input) {
        self.variables = Variables(input: input)
    }

    public convenience init(assignmentID: String, postPolicy: PostGradePolicy) {
        self.init(input: Input(
            gradedOnly: postPolicy == .graded,
            assignmentId: assignmentID,
            sectionIds: nil
        ))
    }

    public class var query: String { """
        mutation \(operationName)($input: PostAssignmentGradesInput!) {
          postAssignmentGrades(input: $input) {
            assignment { id }
          }
        }
        """ }
}

public class PostAssignmentGradesForSectionsPostPolicyRequest: PostAssignmentGradesPostPolicyRequest {
    public init(assignmentID: String, postPolicy: PostGradePolicy, sections: [String]) {
        super.init(input: Input(
            gradedOnly: postPolicy == .graded,
            assignmentId: assignmentID,
            sectionIds: sections
        ))
    }

    public override class var query: String { """
        mutation \(operationName)($input: PostAssignmentGradesForSectionInput!) {
          postAssignmentGradesForSection(input: $input) {
            assignment { id }
          }
        }
        """ }
}

public class HideAssignmentGradesPostPolicyRequest: APIGraphQLRequestable {
    public typealias Response = APINoContent
    public struct Input: Codable, Equatable {
        public let assignmentId: String
        public let sectionIds: [String]?
    }
    public struct Variables: Codable, Equatable {
        let input: Input
    }
    public let variables: Variables

    init(input: Input) {
        variables = Variables(input: input)
    }

    public convenience init(assignmentID: String) {
        self.init(input: Input(assignmentId: assignmentID, sectionIds: nil))
    }

    public class var query: String { """
        mutation \(operationName)($input: HideAssignmentGradesInput!) {
          hideAssignmentGrades(input: $input) {
            assignment { id }
          }
        }
        """ }
}

public class HideAssignmentGradesForSectionsPostPolicyRequest: HideAssignmentGradesPostPolicyRequest {
    public init(assignmentID: String, sections: [String]) {
        super.init(input: Input(assignmentId: assignmentID, sectionIds: sections))
    }

    public override class var query: String { """
        mutation \(operationName)($input: HideAssignmentGradesForSectionsInput!) {
          hideAssignmentGradesForSections(input: $input) {
            assignment { id }
          }
        }
        """ }
}

public struct GetAssignmentPostPolicyInfoRequest: APIGraphQLRequestable {
    public typealias Response = APIPostPolicyInfo
    public struct Variables: Codable, Equatable {
        public let courseID: String
        public let assignmentID: String
    }
    public let variables: Variables

    public init(courseID: String, assignmentID: String) {
        variables = Variables(courseID: courseID, assignmentID: assignmentID)
    }

    public static let query = """
        query \(operationName)($courseID: ID!, $assignmentID: ID!) {
          course(id: $courseID) {
            sections: sectionsConnection {
              nodes {
                id
                name
              }
            }
          }
          assignment(id: $assignmentID) {
            submissions: submissionsConnection {
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
