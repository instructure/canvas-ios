//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import Core

struct StudentSubAssignmentsCardViewModel {

    let items: [StudentSubAssignmentsCardItem]

    init(assignment: Assignment, submission: Submission?) {
        guard assignment.hasSubAssignments else {
            self.items = []
            return
        }

        self.items = assignment.checkpoints
            .map { checkpoint in
                let subSubmission = submission?.subAssignmentSubmissions
                    .first { $0.subAssignmentTag == checkpoint.tag }

                let status = subSubmission?.status ?? .notSubmitted

                var score: String?
                if let pointsPossible = checkpoint.pointsPossible, !status.isExcused {
                    score = GradeFormatter.string(
                        pointsPossible: pointsPossible,
                        gradingType: assignment.gradingType,
                        gradingScheme: assignment.gradingScheme,
                        hideScores: assignment.hideQuantitativeData,
                        style: .medium,
                        isExcused: false,
                        score: subSubmission?.score,
                        normalizedScore: (subSubmission?.score).map { $0 / pointsPossible },
                        grade: subSubmission?.grade
                    )
                }
                let scoreA11yLabel = score.flatMap {
                    [String(localized: "Grade", bundle: .core), GradeFormatter.a11yString(from: $0)]
                        .accessibilityJoined()
                }

                return StudentSubAssignmentsCardItem(
                    id: checkpoint.tag,
                    title: checkpoint.title,
                    submissionStatus: status.labelModel,
                    score: score,
                    scoreA11yLabel: scoreA11yLabel
                )
            }
    }
}

#if DEBUG

extension StudentSubAssignmentsCardViewModel {
    init(items: [StudentSubAssignmentsCardItem]) {
        self.items = items
    }
}

#endif
