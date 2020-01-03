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

public struct PostAssignmentGradesPostPolicyRequest: APIGraphQLRequestable {
    public typealias Response = APINoContent

    public let postPolicy: PostGradePolicy
    public let assignmentID: String
    let sections: [String]

    public init(assignmentID: String, postPolicy: PostGradePolicy, sections: [String] = []) {
        self.postPolicy = postPolicy
        self.assignmentID = assignmentID
        self.sections = sections
    }

    public let operationName = "PostAssignmentGrades"
    public var query: String? {
        let mutation = sections.count > 0 ? "postAssignmentGradesForSections" : "postAssignmentGrades"
        let sectionsAsString = "[ \( sections.map { "\"\($0)\"" }.joined(separator: ",") ) ]"
        let sectionIDs = sections.count > 0 ? ", sectionIds: \(sectionsAsString)" : ""
        return """
        mutation \(operationName)
            {
                \(mutation)(input: {assignmentId: "\(assignmentID)", gradedOnly: \(postPolicy == .graded)\(sectionIDs)})
                {
                    assignment { id }
                }
            }
        """
    }
}

public struct HideAssignmentGradesPostPolicyRequest: APIGraphQLRequestable {
    public typealias Response = APINoContent

    public let assignmentID: String
    let sections: [String]

    public init(assignmentID: String, sections: [String] = []) {
        self.assignmentID = assignmentID
        self.sections = sections
    }

    public let operationName = "HideAssignmentGrades"
    public var query: String? {
        let mutation = sections.count > 0 ? "hideAssignmentGradesForSections" : "hideAssignmentGrades"
        let sectionsAsString = "[ \( sections.map { "\"\($0)\"" }.joined(separator: ",") ) ]"
        let sectionIDs = sections.count > 0 ? ", sectionIds: \(sectionsAsString)" : ""
        return """
        mutation \(operationName)
        {
            \(mutation)(input: {assignmentId: "\(assignmentID)"\(sectionIDs)})
            {
                assignment { id }
            }
        }
        """
    }
}

public struct GetAssignmentPostPolicyInfoRequest: APIGraphQLRequestable {
    public typealias Response = APIPostPolicyInfo

    public let courseID: String
    public let assignmentID: String

    public init(courseID: String, assignmentID: String) {
        self.courseID = courseID
        self.assignmentID = assignmentID
    }

    public let operationName = "GetAssignmentPostPolicyInfo"
    public var query: String? {
        return """
        query \(operationName) {
            course(id: "\(courseID)") {
                sections: sectionsConnection {
                  nodes {
                    id
                    name
                  }
                }
              }
              assignment(id: "\(assignmentID)") {
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
}
