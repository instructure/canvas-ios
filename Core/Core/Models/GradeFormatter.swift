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

    public var gradeStyle: Style = .short
    public var gradingType: GradingType = .points
    public var pointsPossible: Double = 0
    public var userID: String?
    public var placeholder = "-"

    public static func string(from assignment: Assignment, userID: String? = nil, style: Style = .medium) -> String? {
        let formatter = GradeFormatter()
        formatter.userID = userID
        formatter.pointsPossible = assignment.pointsPossible ?? 0
        formatter.gradingType = assignment.gradingType
        formatter.gradeStyle = style
        if let userID = userID {
            let submission = assignment.submissions?.first { $0.userID == userID }
            return formatter.string(from: submission)
        }
        return formatter.string(from: assignment.submission)
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
            switch gradeStyle {
            case .short: return format(score)
            case .medium: return medium(score: score)
            }
        case .gpa_scale:
            switch gradeStyle {
            case .short:
                guard let grade = submission.grade else { return nil }
                return String.localizedStringWithFormat(NSLocalizedString("%@ GPA", bundle: .core, comment: ""), grade)
            case .medium:
                return medium(score: score, grade: submission.grade)
            }
        case .percent, .letter_grade:
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
        return GradeFormatter.numberFormatter.string(from: NSNumber(value: number))
    }

    private func medium(score: Double, grade: String? = nil) -> String {
        medium(score: format(score) ?? placeholder, grade: grade)
    }

    private func medium(score: String, grade: String? = nil) -> String {
        let pointsPossible = format(self.pointsPossible) ?? placeholder
        if let grade = grade {
            return "\(score) / \(pointsPossible) (\(grade))"
        }
        return "\(score) / \(pointsPossible)"
    }
}
