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

public struct APIPostPolicyInfo: Codable {
    public var sections: [SectionNode] {
        return data.course.sections.nodes
    }
    public var submissions: [SubmissionNode] {
        return data.assignment.submissions.nodes
    }
    internal var data: PostPolicyData

    public struct SectionNode: Codable, Equatable {
        public let id: String
        public let name: String
    }

    public struct SubmissionNode: Codable, Equatable, PostPolicyLogicProtocol {
        public let score: Double?
        public let excused: Bool
        public let state: String
        public let postedAt: Date?
        public var isGraded: Bool {
            return ( score != nil && state == "graded" ) || excused
        }

        public var isHidden: Bool {
            return isGraded && postedAt == nil
        }

        public var isPosted: Bool {
            return postedAt != nil && isGraded
        }
    }

    struct Sections: Codable {
        var nodes: [APIPostPolicyInfo.SectionNode]
    }

    struct PostPolicyData: Codable {
        var course: Course
        var assignment: Assignment
    }

    struct Course: Codable {
        var sections: Sections
    }

    struct Assignment: Codable {
        var submissions: Submissions
    }

    struct Submissions: Codable {
        var nodes: [APIPostPolicyInfo.SubmissionNode]
    }
}

public protocol PostPolicyLogicProtocol {
    var isGraded: Bool { get }
    var isHidden: Bool { get }
    var isPosted: Bool { get }
}

extension Array where Element: PostPolicyLogicProtocol {
    public var hiddenCount: Int {
        return filter { $0.isHidden }.count
    }

    public var postedCount: Int {
        return filter { $0.isPosted }.count
    }
}

public enum PostGradePolicy: String, CaseIterable {
    case everyone, graded
}

#if DEBUG
extension APIPostPolicyInfo {
    public static func make(
        sections: [APIPostPolicyInfo.SectionNode] = [.make()],
        submissions: [APIPostPolicyInfo.SubmissionNode] = [.make()]
    ) -> Self {
        Self(data: PostPolicyData(
            course: Course(sections: Sections(nodes: sections)),
            assignment: Assignment(submissions: Submissions(nodes: submissions))
        ))
    }
}

extension APIPostPolicyInfo.SectionNode {
    public static func make(
        id: String = "1",
        name: String = "section 1"
    ) -> Self {
        Self(id: id, name: name)
    }
}

extension APIPostPolicyInfo.SubmissionNode {
    public static func make(
        score: Double? = 1.0,
        excused: Bool = false,
        state: String = "graded",
        postedAt: Date? = nil
    ) -> Self {
        Self(
            score: score,
            excused: excused,
            state: state,
            postedAt: postedAt
        )
    }
}
#endif

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
