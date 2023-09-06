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

public class GradeFormatter {
    public enum Style {
        case short
        case medium
    }

    enum PassFail: String {
        case complete, incomplete
        var localizedString: String {
            switch self {
            case .complete:
                return NSLocalizedString("Complete", bundle: .core, comment: "")
            case .incomplete:
                return NSLocalizedString("Incomplete", bundle: .core, comment: "")
            }
        }
    }

    public static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .decimal
        return formatter
    }()

    public static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        formatter.numberStyle = .percent
        return formatter
    }()

    public var gradeStyle: Style = .short
    public var gradingType: GradingType = .points
    public var pointsPossible: Double = 0
    public var placeholder = "-"
    public var hideScores: Bool = false

    public static func a11yString(from assignment: Assignment, userID: String? = nil, style: Style = .medium) -> String? {
        a11yString(from: string(from: assignment, userID: userID, style: style))
    }

    public static func string(from assignment: Assignment, userID: String? = nil, style: Style = .medium) -> String? {
        let formatter = GradeFormatter()
        formatter.pointsPossible = assignment.pointsPossible ?? 0
        formatter.gradingType = assignment.gradingType
        formatter.gradeStyle = style
        formatter.hideScores = assignment.hideQuantitativeData
        if let userID = userID {
            let submission = assignment.submissions?.first { $0.userID == userID }
            return formatter.string(from: submission)
        }
        return formatter.string(from: assignment.submission)
    }

    public static func a11yString(from assignment: Assignment, submission: Submission, style: Style = .medium) -> String? {
        a11yString(from: string(from: assignment, submission: submission, style: style))
    }

    public static func string(from assignment: Assignment, submission: Submission, style: Style = .medium) -> String? {
        let formatter = GradeFormatter()
        formatter.pointsPossible = assignment.pointsPossible ?? 0
        formatter.gradingType = assignment.gradingType
        formatter.gradeStyle = style
        formatter.hideScores = assignment.hideQuantitativeData
        if assignment.gradingType == .letter_grade {
            formatter.gradeStyle = .short
        }
        return formatter.string(from: submission)
    }

    private static func a11yString(from formattedGrade: String?) -> String? {
        guard var formattedGrade = formattedGrade else { return nil }

        formattedGrade = formattedGrade.replacingOccurrences(of: " / ", with: "/")
        formattedGrade = formattedGrade.replacingOccurrences(of: "/", with: " " + NSLocalizedString("out of", comment: "5 out of 10") + " ")

        return formattedGrade
    }

    public func a11yString(from submission: Submission?) -> String? {
        GradeFormatter.a11yString(from: string(from: submission))
    }

    public func string(from submission: Submission?) -> String? {
        let isExcused = submission?.excused == true
        guard let submission = submission, let score = submission.score, !isExcused else {
            let excused = NSLocalizedString("Excused", bundle: .core, comment: "")
            switch gradeStyle {
            case .short: return isExcused ? excused : nil
            case .medium: return isExcused ? medium(score: excused) : medium(score: placeholder)
            }
        }
        switch gradingType {
        case .pass_fail:
            let grade = submission.grade.flatMap(PassFail.init(rawValue:))
            switch gradeStyle {
            case .short: return grade?.localizedString
            case .medium: return medium(score: grade?.localizedString ?? placeholder)
            }
        case .points:
            if hideScores {
                if let normalizedScore = submission.normalizedScore,
                   let converterLetterGrade =  submission.assignment?.gradingScheme.convertScoreToLetterGrade(score: normalizedScore) {
                    return converterLetterGrade
                } else {
                    return placeholder
                }
            }
            switch gradeStyle {
            case .short: return format(score)
            case .medium: return medium(score: score)
            }
        case .gpa_scale:
            if hideScores {
                if let grade = submission.grade, !grade.containsNumber {
                    return String.localizedStringWithFormat(NSLocalizedString("%@ GPA", bundle: .core, comment: ""), grade)
                }
                return nil
            }
            switch gradeStyle {
            case .short:
                guard let grade = submission.grade else { return nil }
                return String.localizedStringWithFormat(NSLocalizedString("%@ GPA", bundle: .core, comment: ""), grade)
            case .medium:
                return medium(score: score, grade: submission.grade)
            }
        case .percent:
            if hideScores {
                if let normalizedScore = submission.normalizedScore,
                   let converterLetterGrade =  submission.assignment?.gradingScheme.convertScoreToLetterGrade(score: normalizedScore) {
                    return converterLetterGrade
                } else {
                    return placeholder
                }
            }
            switch gradeStyle {
            case .short:
                return submission.grade
            case .medium:
                return medium(score: score, grade: submission.grade)
            }
        case .letter_grade:
            switch gradeStyle {
            case .short:
                return submission.grade
            case .medium:
                return medium(score: score, grade: submission.grade)
            }
        case .not_graded:
            return nil
        }
    }

    private func format(_ number: Double) -> String? {
        if hideScores {
            return nil
        }
        return GradeFormatter.numberFormatter.string(from: GradeFormatter.truncate(number))
    }

    private func medium(score: Double, grade: String? = nil) -> String {
        medium(score: format(score) ?? placeholder, grade: grade)
    }

    private func medium(score: String, grade: String? = nil) -> String {
        if hideScores {
            return grade ?? (score.containsNumber ? "" : score)
        }
        let pointsPossible = format(self.pointsPossible) ?? placeholder
        if let grade = grade {
            return "\(score) / \(pointsPossible) (\(grade))"
        }
        return "\(score) / \(pointsPossible)"
    }

    public static func truncate(_ value: Double, factor: Double = 100) -> NSNumber {
        let rounded = round(value * factor) / factor
        return NSNumber(value: rounded)
    }

    // For teachers & graders in submission list
    public static func shortString(for assignment: Assignment?, submission: Submission?) -> String {
        guard assignment?.gradingType != .not_graded else { return "" }

        let placeholder = NSLocalizedString("--", comment: "placeholder for the score of an ungraded submission")
        guard let assignment = assignment, let submission = submission,
            submission.workflowState != .unsubmitted, !submission.needsGrading
        else { return placeholder }

        guard submission.excused != true else { return NSLocalizedString("Excused", comment: "") }

        return gradeString(for: assignment, submission: submission) ?? placeholder
    }

    public static func gradeString(for assignment: Assignment, submission: Submission, final: Bool = true) -> String? {
        let grade = final ? submission.grade : submission.enteredGrade
        let score = final ? submission.score : submission.enteredScore

        let shouldHideScore = assignment.hideQuantitativeData

        switch assignment.gradingType {
        case .percent:
            if shouldHideScore { return "" }
            return (grade?.replacingOccurrences(of: "%", with: "")).flatMap { Double($0) }
                .flatMap { percentFormatter.string(from: truncate($0 / 100, factor: 10000)) }
        case .points:
            if shouldHideScore { return "" }
            return (score ?? grade.flatMap { Double($0) })
                .flatMap { numberFormatter.string(from: truncate($0)) }
        default:
            switch grade {
            case "pass":
                return NSLocalizedString("Pass", comment: "")
            case "fail":
                return NSLocalizedString("Fail", comment: "")
            case "complete":
                return NSLocalizedString("Complete", comment: "")
            case "incomplete":
                return NSLocalizedString("Incomplete", comment: "")
            default:
                if shouldHideScore, grade?.containsNumber == true { return "" }
                return grade.flatMap { Double($0) }
                    .flatMap { numberFormatter.string(from: truncate($0)) }
                    ?? grade
            }
        }
    }

    public static func longString(for assignment: Assignment, submission: Submission, rubricScore: Double? = nil, final: Bool = true) -> String {
        let score = (final ? submission.score : rubricScore ?? submission.enteredScore) ?? 0
        let scoreString = numberFormatter.string(from: truncate(score)) ?? "0"
        let possibleString = numberFormatter.string(from: truncate(assignment.pointsPossible ?? 0)) ?? "0"
        let grade = assignment.gradingType == .points ? nil : gradeString(for: assignment, submission: submission, final: final)
        if assignment.hideQuantitativeData {
            return grade ?? ""
        }
        if let grade = grade {
            return String.localizedStringWithFormat(
                NSLocalizedString("%@/%@ (%@)", comment: "score/points possible (grade)"),
                scoreString, possibleString, grade
            )
        }
        return String.localizedStringWithFormat(
            NSLocalizedString("%@/%@", comment: "score/points"),
            scoreString, possibleString
        )
    }
}
