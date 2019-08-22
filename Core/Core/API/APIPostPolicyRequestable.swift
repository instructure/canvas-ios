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

public struct PostAssignmentGradesPostPolicyRequest: GraphqlRequestable {
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
    public typealias Response = APIPostPolicyInfo

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
