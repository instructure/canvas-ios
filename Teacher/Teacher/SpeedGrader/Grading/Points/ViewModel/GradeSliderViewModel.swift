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

class GradeSliderViewModel {

    /// Represents the different grade precision modes based on maximum points
    private enum GradePrecisionMode {
        case quarters
        case halves
        case wholes

        init(maxPoints: Double) {
            if maxPoints <= 10 {
                self = .quarters
            } else if maxPoints <= 20 {
                self = .halves
            } else {
                self = .wholes
            }
        }

        var stepValue: Double {
            switch self {
            case .quarters: return 0.25
            case .halves: return 0.5
            case .wholes: return 1.0
            }
        }

        var formatString: String {
            switch self {
            case .quarters: return "%.2f"
            case .halves: return "%.1f"
            case .wholes: return "%.0f"
            }
        }
    }

    /// Calculates the appropriate step value based on the maximum possible points
    /// - Parameter maxPoints: The maximum possible points for the assignment
    /// - Returns: The step value for the slider
    func stepValue(for maxPoints: Double) -> Double {
        GradePrecisionMode(maxPoints: maxPoints).stepValue
    }

    /// Calculates the grade value for a given position with appropriate stepping
    /// - Parameters:
    ///   - position: The x position of the drag gesture
    ///   - width: The total width of the slider
    ///   - maxValue: The maximum possible value (assumes minimum is 0)
    /// - Returns: The calculated grade value with appropriate stepping applied
    func gradeValue(for position: CGFloat, in width: CGFloat, maxValue: Double) -> Double {
        let percent = min(max(0, Double(position / width)), 1)
        let rawValue = percent * maxValue
        let step = stepValue(for: maxValue)

        let steppedValue = (rawValue / step).rounded() * step
        return min(max(steppedValue, 0), maxValue)
    }

    /// Formats a score value according to the appropriate decimal places for the given maximum points
    /// - Parameters:
    ///   - score: The score value to format
    ///   - maxPoints: The maximum possible points for the assignment
    /// - Returns: A formatted string with appropriate decimal places
    func formatScore(_ score: Double, maxPoints: Double) -> String {
        let precisionMode = GradePrecisionMode(maxPoints: maxPoints)
        return String(format: precisionMode.formatString, score)
    }
}
