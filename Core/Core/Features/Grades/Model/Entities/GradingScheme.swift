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
    public static var empty: GradingScheme {
        GradingScheme(pointsBased: false, scaleFactor: 1, entries: [])
    }

    public let pointsBased: Bool
    public let scaleFactor: Double
    public let entries: [GradingSchemeEntry]

    public init(pointsBased: Bool, scaleFactor: Double, entries: [GradingSchemeEntry]) {
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
            return Course.scoreFormatter.string(from: NSNumber(value: value))
        }

        guard (0 ... 100).contains(value) else { return nil }

        let normalizedScore = value / 100.0
        let number = NSNumber(value: normalizedScore * scaleFactor)

        return Self.pointsFormatter.string(from: number)
    }

    private static let pointsFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.multiplier = 1
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .halfEven
        return formatter
    }()
}
