//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

public protocol GradeViewable {
    var gradingType: GradingType { get }
    var pointsPossible: Double? { get }
    var viewableGrade: String? { get }
    var viewableScore: Double? { get }
}

extension GradeViewable {
    public var pointsPossibleText: String? {
        guard let points = pointsPossible else {
            return NSLocalizedString("Not Graded", bundle: .core, comment: "")
        }
        let format = NSLocalizedString("g_pts", bundle: .core, comment: "")
        return String.localizedStringWithFormat(format, points)
    }

    public var pointsText: String? {
        guard let score = viewableScore else { return nil }
        let format = NSLocalizedString("plural_points", bundle: .core, comment: "")
        return String.localizedStringWithFormat(format, score)
    }

    public var outOfText: String? {
        guard let points = pointsPossible else { return nil }
        let format = NSLocalizedString("out_of_g_pts", bundle: .core, comment: "")
        return String.localizedStringWithFormat(format, points)
    }

    public var scoreOutOfPointsPossibleText: String? {
        guard let score = viewableScore, let points = pointsPossible else { return nil }
        let format = NSLocalizedString("g_out_of_g_points_possible", bundle: .core, comment: "")
        return String.localizedStringWithFormat(format, score, points)
    }

    public var gradeText: String? {
        switch gradingType {
        case .gpa_scale:
            guard let grade = viewableGrade else { return nil }
            let format = NSLocalizedString("%@ GPA", bundle: .core, comment: "")
            return String.localizedStringWithFormat(format, grade)

        case .pass_fail:
            guard let score = viewableScore else { return nil }
            return score == 0
                ? NSLocalizedString("Incomplete", bundle: .core, comment: "")
                : NSLocalizedString("Complete", bundle: .core, comment: "")

        case .letter_grade, .percent, .points, .not_graded:
            return viewableGrade
        }
    }

    public var finalGradeText: String? {
        if gradingType == .points, let score = viewableScore {
            let format = NSLocalizedString("final_grade_g_pts", bundle: .core, comment: "")
            return String.localizedStringWithFormat(format, score)
        } else if let grade = viewableGrade {
            let format = NSLocalizedString("Final Grade: %@", bundle: .core, comment: "")
            return String.localizedStringWithFormat(format, grade)
        }
        return nil
    }
}
