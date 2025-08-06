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
        gradingScheme: GradingScheme?,
        isRubricScoreAvailable: Bool, // TODO: remove if not needed for rubrics
        totalRubricScore: Double // TODO: remove if not needed for rubrics
    ) -> GradeState
}

class GradeStateInteractorLive: GradeStateInteractor {

    func gradeState(
        submission: Submission,
        assignment: Assignment,
        gradingScheme: GradingScheme? = nil,
        isRubricScoreAvailable: Bool,
        totalRubricScore: Double
    ) -> GradeState {
        let gradingType = assignment.gradingType

        let isGraded = (submission.grade?.isEmpty == false)
        let hasLatePenaltyPoints = (submission.pointsDeducted ?? 0) > 0
        let isExcused = (submission.excused == true)
        let score = submission.enteredScore ?? submission.score ?? 0

        return GradeState(
            gradingType: gradingType,
            pointsPossibleText: assignment.pointsPossibleText,
            gradeOptions: Self.gradeOptions(for: gradingType, gradingScheme: gradingScheme),

            isGraded: isGraded,
            isExcused: isExcused,
            isGradedButNotPosted: (isGraded && submission.postedAt == nil),
            hasLateDeduction: submission.late && isGraded && hasLatePenaltyPoints,

            score: score,
            originalGrade: submission.enteredGrade,
            originalScoreWithoutMetric: GradeFormatter.originalScoreWithoutMetric(for: submission),
            originalGradeWithoutMetric: GradeFormatter.originalGradeWithoutMetric(for: submission, gradingType: gradingType),
            finalGradeWithoutMetric: GradeFormatter.finalGradeWithoutMetric(for: submission, gradingType: gradingType),
            pointsDeductedText: String(localized: "\(-(submission.pointsDeducted ?? 0), specifier: "%g") pts", bundle: .core)
        )
    }

    /// Returns a placeholder GradeState which sets only the properties available from `assignment`.
    static func gradeState(usingOnly assignment: Assignment, gradingScheme: GradingScheme? = nil) -> GradeState {
        let gradingType = assignment.gradingType

        return GradeState(
            gradingType: gradingType,
            pointsPossibleText: assignment.pointsPossibleText,
            gradeOptions: gradeOptions(for: gradingType, gradingScheme: gradingScheme),

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

    private static func gradeOptions(for gradingType: GradingType, gradingScheme: GradingScheme? = nil) -> [OptionItem] {
        switch gradingType {
        case .gpa_scale, .letter_grade:
            guard let gradingScheme else { return [] }

            var items: [OptionItem] = []
            let maxValue = gradingScheme.formattedMaxValue ?? ""
            var upperBound = maxValue
            gradingScheme.formattedEntries.forEach {
                let lowerBound = $0.value

                let subtitle: String
                if upperBound == maxValue {
                    subtitle = String(localized: "\(maxValue) to \(lowerBound)", bundle: .teacher, comment: "'100% to 94%', or '400 to 230'")
                } else {
                    subtitle = String(localized: "< \(upperBound) to \(lowerBound)", bundle: .teacher, comment: "'< 94% to 84%', or '< 230 to 160'")
                }

                let a11yLabel = [String.accessibiltyLetterGrade($0.name), subtitle].joined(separator: ",")

                items.append(
                    OptionItem(
                        id: $0.name,
                        title: $0.name,
                        subtitle: subtitle,
                        customAccessibilityLabel: a11yLabel
                    )
                )

                upperBound = lowerBound
            }
            return items
        case .pass_fail:
            return [
                .init(id: "complete", title: String(localized: "Complete", bundle: .teacher)),
                .init(id: "incomplete", title: String(localized: "Incomplete", bundle: .teacher))
            ]
        case .percent, .points, .not_graded:
            return []
        }
    }
}

// MARK: - Mock

public final class GradeStateInteractorMock: GradeStateInteractor {

    private(set) var gradeStateCallsCount = 0
    private(set) var gradeStateInput: (submission: Submission, assignment: Assignment, isRubricScoreAvailable: Bool, totalRubricScore: Double)?
    var gradeStateOutput: GradeState?

    func gradeState(
        submission: Submission,
        assignment: Assignment,
        gradingScheme: GradingScheme?,
        isRubricScoreAvailable: Bool,
        totalRubricScore: Double
    ) -> GradeState {
        gradeStateInput = (submission, assignment, isRubricScoreAvailable, totalRubricScore)
        gradeStateCallsCount += 1
        return gradeStateOutput ?? .empty
    }
}
