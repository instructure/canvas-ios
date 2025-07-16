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
    static let empty = GradeState(
        hasLateDeduction: false,
        isGraded: false,
        isExcused: false,
        isGradedButNotPosted: false,
        finalGradeText: "",
        gradeText: "",
        pointsDeductedText: "",
        gradeAlertText: "",
        score: 0
    )

    let hasLateDeduction: Bool
    let isGraded: Bool
    let isExcused: Bool
    let isGradedButNotPosted: Bool

    /// The final grade after late deduction is applied.
    let finalGradeText: String

    /// Late deduction is applied to this resulting in the final grade.
    let originalGradeText: String

    /// Formatted text showing points deducted for late submissions.
    let pointsDeductedText: String

    /// Text to display in grade alert during manual score entry.
    let gradeAlertText: String

    /// The numerical score value for the submission.
    /// Uses entered score if available, otherwise falls back to calculated score.
    let score: Double

    init(
        hasLateDeduction: Bool,
        isGraded: Bool,
        isExcused: Bool,
        isGradedButNotPosted: Bool,
        finalGradeText: String,
        gradeText: String,
        pointsDeductedText: String,
        gradeAlertText: String,
        score: Double
    ) {
        self.hasLateDeduction = hasLateDeduction
        self.isGraded = isGraded
        self.isExcused = isExcused
        self.isGradedButNotPosted = isGradedButNotPosted
        self.finalGradeText = finalGradeText
        self.originalGradeText = gradeText
        self.pointsDeductedText = pointsDeductedText
        self.gradeAlertText = gradeAlertText
        self.score = score
    }
}
