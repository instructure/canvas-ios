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

import Foundation

public enum GradingType: String, Codable, CaseIterable {
    case percent, pass_fail, points, letter_grade, gpa_scale, not_graded

    var string: String {
        switch self {
        case .percent:
            return String(localized: "Percentage", bundle: .core)
        case .pass_fail:
            return String(localized: "Complete/Incomplete", bundle: .core)
        case .points:
            return String(localized: "Points", bundle: .core)
        case .letter_grade:
            return String(localized: "Letter Grade", bundle: .core)
        case .gpa_scale:
            return String(localized: "GPA Scale", bundle: .core)
        case .not_graded:
            return String(localized: "Not Graded", bundle: .core)
        }
    }
}
