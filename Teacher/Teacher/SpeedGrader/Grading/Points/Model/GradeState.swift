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
    let gradeOptions: [OptionItem]

    // MARK: - Status

    let isGraded: Bool
    let isExcused: Bool
    let isGradedButNotPosted: Bool
    let hasLateDeduction: Bool

    // MARK: - Scores & Grades

    /// The numerical score value for the submission.
    /// Uses entered score if available, otherwise falls back to calculated score.
    let score: Double

    let originalGrade: String?

    let originalScoreWithoutMetric: String?

    let originalGradeWithoutMetric: String?

    let finalGradeWithoutMetric: String?

    /// Formatted text showing points deducted for late submissions.
    let pointsDeductedText: String
}

extension GradeState {
    static let empty = GradeState(
        gradingType: .not_graded,
        pointsPossibleText: "",
        gradeOptions: [],
        isGraded: false,
        isExcused: false,
        isGradedButNotPosted: false,
        hasLateDeduction: false,
        score: 0,
        originalGrade: nil,
        originalScoreWithoutMetric: nil,
        originalGradeWithoutMetric: nil,
        finalGradeWithoutMetric: nil,
        pointsDeductedText: ""
    )
}

#if DEBUG

extension GradeState {
    static func make(
        gradingType: GradingType = .not_graded,
        pointsPossibleText: String = "",
        gradeOptions: [OptionItem] = [],
        isGraded: Bool = false,
        isExcused: Bool = false,
        isGradedButNotPosted: Bool = false,
        hasLateDeduction: Bool = false,
        score: Double = 0,
        originalGrade: String? = nil,
        originalScoreWithoutMetric: String? = nil,
        originalGradeWithoutMetric: String? = nil,
        finalGradeWithoutMetric: String? = nil,
        pointsDeductedText: String = ""
    ) -> GradeState {
        .init(
            gradingType: gradingType,
            pointsPossibleText: pointsPossibleText,
            gradeOptions: gradeOptions,
            isGraded: isGraded,
            isExcused: isExcused,
            isGradedButNotPosted: isGradedButNotPosted,
            hasLateDeduction: hasLateDeduction,
            score: score,
            originalGrade: originalGrade,
            originalScoreWithoutMetric: originalScoreWithoutMetric,
            originalGradeWithoutMetric: originalGradeWithoutMetric,
            finalGradeWithoutMetric: finalGradeWithoutMetric,
            pointsDeductedText: pointsDeductedText
        )
    }
}

#endif
