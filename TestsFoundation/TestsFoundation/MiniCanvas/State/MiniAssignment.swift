//
// This file is part of Canvas.
// Copyright (C) $YEAR-present  Instructure, Inc.
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

public class MiniAssignment: Encodable {
    public var api: APIAssignment
    public var submissions: [APISubmission] = []

    public var id: String { api.id.value }

    init(_ assignment: APIAssignment) {
        self.api = assignment
    }

    public func submissionList(state: MiniCanvasState) -> [String: Any] {
        let course = state.course(byId: api.course_id.value)
        return [
            "data": [
                "assignment": [
                    "id": id,
                    "name": api.name,
                    "pointsPossible": api.points_possible,
                    "gradeGroupStudentsIndividually": api.grade_group_students_individually,
                    "anonymousGrading": false,
                    "muted": true,
                    "gradingType": api.grading_type.rawValue,
                    "groupSet": nil,
                    "course": [
                        "name": course?.api.name,
                        "sections": [
                            "edges": [
                                [
                                    "section": ["id": "1", "name": "Section 1", "__typename": "Section"],
                                    "__typename": "SectionEdge",
                                ],
                            ],
                            "__typename": "SectionConnection",
                        ],
                        "__typename": "Course",
                    ] as [String: Any?],
                    "submissions": [
                        "edges": submissions.map { (submission: APISubmission) -> [String: Any?] in
                            let user = state.user(byId: submission.user_id.value)
                            return [
                                "submission": [
                                    "grade": submission.grade,
                                    "score": submission.score,
                                    "late": submission.late,
                                    "missing": submission.missing,
                                    "excused": submission.excused,
                                    "submittedAt": submission.submitted_at?.isoString(),
                                    "gradingStatus": "needs_grading",
                                    "gradeMatchesCurrentSubmission": submission.grade_matches_current_submission,
                                    "state": submission.workflow_state.rawValue,
                                    "postedAt": nil,
                                    "user": [
                                        "id": user?.id.value,
                                        "avatarUrl": user?.avatar_url?.rawValue.absoluteString,
                                        "name": user?.name,
                                        "pronouns": user?.pronouns,
                                        "__typename": "User",
                                    ] as [String: Any?],
                                    "__typename": "Submission",
                                ],
                                "__typename": "SubmissionEdge",
                            ]
                        },
                        "__typename": "SubmissionConnection",
                    ],
                    "groupedSubmissions": nil,
                    "__typename": "Assignment",
                ],
            ],
        ]
    }
}
