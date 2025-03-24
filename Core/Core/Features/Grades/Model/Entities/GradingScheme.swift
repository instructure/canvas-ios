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

public struct GradingScheme {

    public let pointsBased: Bool
    public let scaleFactor: Double
    public let entries: [GradingSchemeEntry]

    fileprivate init(pointsBased: Bool, scaleFactor: Double, entries: [GradingSchemeEntry]) {
        self.pointsBased = pointsBased
        self.scaleFactor = scaleFactor
        self.entries = entries
    }

    public func convertScoreToLetterGrade(score: Double) -> String? {
        let normalizedScore = score / 100.0
        return entries.first { normalizedScore >= $0.value }?.name
    }

    public func formattedScore(from value: Double) -> String? {
        guard pointsBased else {
            return Self.percentFormatter.string(from: NSNumber(value: value))
        }

        let normalizedScore = value / 100.0
        let number = NSNumber(value: normalizedScore * scaleFactor)

        return Self.pointsFormatter.string(from: number)
    }

    // MARK: Formatters

    private static let pointsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.multiplier = 1
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .halfEven
        return formatter
    }()

    private static let percentFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.decimalSeparator = "."
        formatter.multiplier = 1
        formatter.maximumFractionDigits = 3
        formatter.roundingMode = .down
        return formatter
    }()
}

// MARK: - Schemes for Previews & Testing

#if DEBUG

public extension GradingScheme {

    static var percentageBased: GradingScheme {
        GradingScheme(pointsBased: false, scaleFactor: 1, entries: [])
    }

    static var pointsBased: GradingScheme {
        GradingScheme(pointsBased: true, scaleFactor: 4, entries: [])
    }
}

#endif

// MARK: - As Course's property

extension Course {

    public var gradingScheme: GradingScheme {
        return GradingScheme(
            pointsBased: pointsBasedGradingScheme,
            scaleFactor: scalingFactor,
            entries: gradingSchemeEntries
        )
    }
}
