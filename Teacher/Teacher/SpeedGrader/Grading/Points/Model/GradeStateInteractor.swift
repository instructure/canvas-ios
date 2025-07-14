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

/// Protocol for calculating grade state based on submission, assignment, and rubric data.
/// Abstracts the grade state calculation logic to enable easier testing.
protocol GradeStateInteractor {
    func gradeState(
        submission: Submission,
        assignment: Assignment,
        isRubricScoreAvailable: Bool,
        totalRubricScore: Double
    ) -> GradeState
}

class GradeStateInteractorLive: GradeStateInteractor {

    func gradeState(
        submission: Submission,
        assignment: Assignment,
        isRubricScoreAvailable: Bool,
        totalRubricScore: Double
    ) -> GradeState {
        let isGraded = (submission.grade?.isEmpty == false)
        let hasLatePenaltyPoints = (submission.pointsDeducted ?? 0) > 0
        let isExcused = (submission.excused == true)

        return GradeState(
            hasLateDeduction: submission.late && isGraded && hasLatePenaltyPoints,
            isGraded: isGraded,
            isExcused: isExcused,
            isGradedButNotPosted: (isGraded && submission.postedAt == nil),
            finalGradeText: GradeFormatter.longString(for: assignment, submission: submission, final: true),
            gradeText: GradeFormatter.longString(
                for: assignment,
                submission: submission,
                rubricScore: isRubricScoreAvailable ? totalRubricScore : nil,
                final: false
            ),
            pointsDeductedText: String(localized: "\(-(submission.pointsDeducted ?? 0), specifier: "%g") pts", bundle: .core),
            gradeAlertText: {
                if isExcused {
                    return String(localized: "Excused", bundle: .teacher)
                }

                if submission.late, isGraded, hasLatePenaltyPoints {
                    return submission.enteredGrade ?? ""
                }

                return submission.grade ?? ""
            }(),
            score: submission.enteredScore ?? submission.score ?? 0
        )
    }
}
