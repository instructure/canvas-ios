//
// This file is part of Canvas.
// Copyright (C) 2020-present  Instructure, Inc.
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

public class MiniAssignment {
    public var api: APIAssignment
    public var submissions: [MiniSubmission]

    public var id: String { api.id.value }

    public func submission(byUserId id: String?) -> MiniSubmission? {
        submissions.first { $0.api.user_id.value == id }
    }

    public init(_ assignment: APIAssignment, state: MiniCanvasState, submissions: [MiniSubmission] = []) {
        api = assignment
        self.submissions = submissions
    }

    public func add(submission: APISubmission) {
        submissions.append(MiniSubmission(submission))
        api.submission = APIList(values: submissions.map(\.api))
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
                    "gradingType": api.grading_type.rawValue,
                    "groupSet": nil,
                    "course": [
                        "name": course?.api.name,
                        "sections": [
                            "edges": [
                                [
                                    "section": ["id": "1", "name": "Section 1", "__typename": "Section"],
                                    "__typename": "SectionEdge"
                                ]
                            ],
                            "__typename": "SectionConnection"
                        ],
                        "__typename": "Course"
                    ] as [String: Any?],
                    "submissions": [
                        "edges": submissions.map { (submission: MiniSubmission) -> [String: Any?] in
                            let user = state.user(byId: submission.api.user_id.value)
                            return [
                                "submission": [
                                    "grade": submission.api.grade,
                                    "score": submission.api.score,
                                    "late": submission.api.late,
                                    "missing": submission.api.missing,
                                    "excused": submission.api.excused,
                                    "submittedAt": submission.api.submitted_at?.isoString(),
                                    "gradingStatus": "needs_grading",
                                    "gradeMatchesCurrentSubmission": submission.api.grade_matches_current_submission,
                                    "state": submission.api.workflow_state.rawValue,
                                    "postedAt": nil,
                                    "user": [
                                        "id": user?.id.value,
                                        "avatarUrl": user?.avatar_url?.rawValue.absoluteString,
                                        "name": user?.name,
                                        "pronouns": user?.pronouns,
                                        "__typename": "User"
                                    ] as [String: Any?],
                                    "__typename": "Submission"
                                ],
                                "__typename": "SubmissionEdge"
                            ]
                        },
                        "__typename": "SubmissionConnection"
                    ],
                    "groupedSubmissions": nil,
                    "__typename": "Assignment"
                ]
            ]
        ]
    }
}
