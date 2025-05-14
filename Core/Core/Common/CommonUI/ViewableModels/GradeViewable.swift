//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

public protocol GradeViewable {
    var gradingType: GradingType { get }
    var pointsPossible: Double? { get }
    var viewableGrade: String? { get }
    var viewableScore: Double? { get }
    /** The score given by the teacher before late penalty is deducted. */
    var viewableEnteredScore: Double? { get }
}

extension GradeViewable {
    public var pointsPossibleText: String {
        guard let points = pointsPossible else {
            return String(localized: "Not Graded", bundle: .core)
        }
        let format = String(localized: "g_pts", bundle: .core)
        return String.localizedStringWithFormat(format, points)
    }

    public var pointsPossibleCompleteText: String {
        guard let points = pointsPossible else {
            return String(localized: "Not Graded", bundle: .core)
        }
        let format = String(localized: "g_points", bundle: .core)
        return String.localizedStringWithFormat(format, points)
    }

    public var pointsText: String? {
        guard let score = viewableScore else { return nil }
        let format = String(localized: "plural_points", bundle: .core)
        return String.localizedStringWithFormat(format, score)
    }

    public var outOfText: String? {
        guard let points = pointsPossible else { return nil }
        let format = String(localized: "out_of_g_pts", bundle: .core)
        return String.localizedStringWithFormat(format, points)
    }

    public var scoreOutOfPointsPossibleText: String? {
        guard let score = viewableScore, let points = pointsPossible else { return nil }
        let format = String(localized: "g_out_of_g_points_possible", bundle: .core)
        return String.localizedStringWithFormat(format, score, points)
    }

    /** This is used to communicate the original score received before late penalty is deducted. */
    public var enteredGradeText: String? {
        if let score = viewableEnteredScore {
            return String(localized: "Your Grade: \(score, specifier: "%.0f") pt",
                          bundle: .core)
        }
        return nil
    }

    public var finalGradeText: String? {
        if gradingType == .points, let score = viewableScore {
            let format = String(localized: "final_grade_g_pts", bundle: .core)
            return String.localizedStringWithFormat(format, score)
        } else if let grade = viewableGrade {
            let format = String(localized: "Final Grade: %@", bundle: .core)
            return String.localizedStringWithFormat(format, grade)
        }
        return nil
    }
}
