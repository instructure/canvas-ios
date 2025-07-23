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

/// Represents the current state of a student's grade for a submission in SpeedGrader.
/// This model encapsulates all grade-related information including status flags,
/// formatted text for display, and the numerical score value.
struct GradeState: Equatable {

    // MARK: - Assignment level

    let gradingType: GradingType
    let pointsPossibleText: String

    // MARK: - Status

    let isGraded: Bool
    let isExcused: Bool
    let isGradedButNotPosted: Bool
    let hasLateDeduction: Bool

    // MARK: - Scores & Grades

    /// The numerical score value for the submission.
    /// Uses entered score if available, otherwise falls back to calculated score.
    let score: Double

    let originalScoreWithoutMetric: String?

    let originalGradeWithoutMetric: String?

    let finalGradeWithoutMetric: String?

    /// Formatted text showing points deducted for late submissions.
    let pointsDeductedText: String

    // MARK: - Old UI (will be removed)

    /// Late deduction is applied to this resulting in the final grade.
    let originalGradeText: String

    /// Text to display in grade alert during manual score entry.
    let gradeAlertText: String
}

extension GradeState {
    static let empty = GradeState(
        gradingType: .points,
        pointsPossibleText: "",
        isGraded: false,
        isExcused: false,
        isGradedButNotPosted: false,
        hasLateDeduction: false,
        score: 0,
        originalScoreWithoutMetric: nil,
        originalGradeWithoutMetric: nil,
        finalGradeWithoutMetric: nil,
        pointsDeductedText: "",
        originalGradeText: "",
        gradeAlertText: ""
    )
}
