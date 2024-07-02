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

public struct SubmissionListFixture {
    public static let submissionList = [
        "data": [
            "assignment": [
                "id": "1",
                "name": "Assignment 1",
                "pointsPossible": 10,
                "gradeGroupStudentsIndividually": false,
                "anonymousGrading": false,
                "gradingType": "points",
                "groupSet": nil,
                "course": [
                    "name": "Course 1",
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
                ],
                "submissions": [
                    "edges": [
                        [
                            "submission": [
                                "grade": nil,
                                "score": nil,
                                "late": false,
                                "missing": false,
                                "excused": false,
                                "submittedAt": "2019-08-10T16:37:58-06:00",
                                "gradingStatus": "needs_grading",
                                "gradeMatchesCurrentSubmission": true,
                                "state": "submitted",
                                "postedAt": nil,
                                "user": ["id": "1", "avatarUrl": nil, "name": "User 1", "pronouns": nil, "__typename": "User"],
                                "__typename": "Submission"
                            ],
                            "__typename": "SubmissionEdge"
                        ],
                        [
                            "submission": [
                                "grade": nil,
                                "score": nil,
                                "late": false,
                                "missing": false,
                                "excused": false,
                                "submittedAt": "2019-08-10T16:37:58-06:00",
                                "gradingStatus": "needs_grading",
                                "gradeMatchesCurrentSubmission": true,
                                "state": "submitted",
                                "postedAt": nil,
                                "user": ["id": "2", "avatarUrl": nil, "name": "User 2", "pronouns": nil, "__typename": "User"],
                                "__typename": "Submission"
                            ],
                            "__typename": "SubmissionEdge"
                        ],
                        [
                            "submission": [
                                "grade": nil,
                                "score": nil,
                                "late": false,
                                "missing": false,
                                "excused": false,
                                "submittedAt": "2019-08-10T16:37:58-06:00",
                                "gradingStatus": "needs_grading",
                                "gradeMatchesCurrentSubmission": true,
                                "state": "submitted",
                                "postedAt": nil,
                                "user": ["id": "3", "avatarUrl": nil, "name": "User 3", "pronouns": nil, "__typename": "User"],
                                "__typename": "Submission"
                            ],
                            "__typename": "SubmissionEdge"
                        ]
                    ],
                    "__typename": "SubmissionConnection"
                ],
                "groupedSubmissions": nil,
                "__typename": "Assignment"
            ]
        ]
    ]
}
