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
@testable import Core

extension APIPageInfo {
    public static func make(endCursor: String? = nil, hasNextPage: Bool = false) -> APIPageInfo {
        return APIPageInfo(endCursor: endCursor, hasNextPage: hasNextPage)
    }
}

extension APIAssignmentListGroup {
    public static func make(id: ID =  "1",
                            name: String = "GroupA",
                            assignments: [APIAssignmentListAssignment] = [APIAssignmentListAssignment.make()],
                            pageInfo: APIPageInfo? = APIPageInfo.make() )
        -> APIAssignmentListGroup {
            return APIAssignmentListGroup(id: id,
                                          name: name,
                                          assignmentNodes: APIAssignmentListGroup.Nodes(nodes: assignments,
                                                                                        pageInfo: pageInfo))
    }
}

extension APIAssignmentListAssignment {
    public static func make(id: ID = "1", name: String = "A", inClosedGradingPeriod: Bool = false, dueAt: Date? = nil,
                            lockAt: Date? =  nil, unlockAt: Date? = nil, htmlUrl: String? = "/courses/1/assignments/1",
                            submissionTypes: [SubmissionType] = [.online_text_entry], quizID: ID? = nil) -> APIAssignmentListAssignment {
        return APIAssignmentListAssignment(id: id, name: name, inClosedGradingPeriod: inClosedGradingPeriod,
                                           dueAt: dueAt, lockAt: lockAt, unlockAt: unlockAt, htmlUrl: htmlUrl,
                                           submissionTypes: submissionTypes,
                                           quiz: quizID != nil ? APIAssignmentListAssignment.Quiz(id: quizID!) : nil)
    }

    public init(apiAssignment assignment: APIAssignment) {
        self = APIAssignmentListAssignment.make(
            id: assignment.id,
            name: assignment.name,
            dueAt: assignment.due_at,
            lockAt: assignment.lock_at,
            unlockAt: assignment.unlock_at,
            htmlUrl: assignment.html_url.absoluteString,
            submissionTypes: assignment.submission_types,
            quizID: assignment.quiz_id
        )
    }
}
