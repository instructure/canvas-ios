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

public struct APIPostPolicy {

    public struct AssignmentInfo: Codable {

        struct Data: Codable {
            var assignment: Assignment
        }

        struct Assignment: Codable {
            var submissions: Submissions
        }

        struct Submissions: Codable {
            var nodes: [SubmissionNode]
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

        internal var data: Data

        public var nodes: [SubmissionNode] {
            return data.assignment.submissions.nodes
        }
    }

    public struct CourseInfo: PagedResponse {
        public typealias Page = [SectionNode]

        struct Data: Codable {
            var course: Course
        }

        struct Course: Codable {
            var sections: Sections
        }

        struct Sections: Codable {
            var nodes: [SectionNode]
            let pageInfo: APIPageInfo?
        }

        public struct SectionNode: Codable, Equatable {
            public let id: String
            public let name: String
        }

        internal var data: Data

        public var page: [SectionNode] { data.course.sections.nodes }
        public var pageInfo: APIPageInfo? { data.course.sections.pageInfo }

        public mutating func appendSections(_ info: CourseInfo) {
            let nodes = page + info.data.course.sections.nodes
            let newPageInfo = info.data.course.sections.pageInfo
            data.course.sections = Sections(nodes: nodes, pageInfo: newPageInfo)
        }
    }

    public var assignment: AssignmentInfo?
    public var course: CourseInfo?

    public init(assignment: AssignmentInfo? = nil, course: CourseInfo? = nil) {
        self.assignment = assignment
        self.course = course
    }

    public var sections: [CourseInfo.SectionNode]? { course?.page }
    public var submissions: [AssignmentInfo.SubmissionNode]? { assignment?.data.assignment.submissions.nodes }

    public var sectionsCount: Int { sections?.count ?? 0 }
    public var submissionsCount: Int { submissions?.count ?? 0 }
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

public enum PostGradePolicy: String, CaseIterable, OptionItemIdentifiable {
    case everyone, graded
}

extension APIPostPolicy: PageModel {
    public var nextCursor: String? { course?.pageInfo?.nextCursor }
}

#if DEBUG
extension APIPostPolicy.CourseInfo {
    public static func make(
        sections: [SectionNode] = [.make()]
    ) -> Self {
        Self(data: Data(
            course: Course(sections: Sections(nodes: sections, pageInfo: nil))
        ))
    }
}

extension APIPostPolicy.CourseInfo.SectionNode {
    public static func make(
        id: String = "1",
        name: String = "section 1"
    ) -> Self {
        Self(id: id, name: name)
    }
}

extension APIPostPolicy.AssignmentInfo.SubmissionNode {
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

public struct GetPostPolicyAssignmentSubmissionsRequest: APIGraphQLRequestable {
    public typealias Response = APIPostPolicy.AssignmentInfo
    public struct Variables: Codable, Equatable {
        public let assignmentID: String
    }
    public let variables: Variables

    public init(
        assignmentID: String
    ) {
        variables = Variables(assignmentID: assignmentID)
    }

    public static let query = """
        query \(operationName)($assignmentID: ID!) {
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

public struct GetPostPolicyCourseSectionsRequest: APIGraphQLPagedRequestable {
    public typealias Response = APIPostPolicy.CourseInfo
    public struct Variables: Codable, Equatable {
        public let courseID: String
        public let cursor: String?
        public let pageSize: Int
    }
    public let variables: Variables

    public init(
        courseID: String,
        pageSize: Int = 20,
        cursor: String? = nil
    ) {
        variables = Variables(
            courseID: courseID,
            cursor: cursor,
            pageSize: pageSize
        )
    }

    public static let query = """
        query \(operationName)($courseID: ID!, $pageSize: Int!, $cursor: String) {
          course(id: $courseID) {
            sections: sectionsConnection(first: $pageSize, after: $cursor) {
              nodes {
                id
                name
              }
              pageInfo {
                endCursor
                hasNextPage
              }
            }
          }
        }
        """

    public func nextPageRequest(from response: APIPostPolicy.CourseInfo) -> GetPostPolicyCourseSectionsRequest? {
        guard let info = response.data.course.sections.pageInfo, info.hasNextPage else { return nil }

        return GetPostPolicyCourseSectionsRequest(
            courseID: variables.courseID,
            pageSize: variables.pageSize,
            cursor: info.endCursor
        )
    }
}
