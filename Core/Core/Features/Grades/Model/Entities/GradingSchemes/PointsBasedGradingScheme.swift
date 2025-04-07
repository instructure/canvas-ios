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

public struct PointsBasedGradingScheme: GradingScheme {

    public let scaleFactor: Double
    public let entries: [GradingSchemeEntry]

    public func formattedScore(from value: Double) -> String? {
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

// MARK: - Schemes for Previews & Testing

#if DEBUG

public extension PointsBasedGradingScheme {
    static var `default`: Self {
        PointsBasedGradingScheme(scaleFactor: 4, entries: [])
    }
}

public extension GradingScheme where Self == PointsBasedGradingScheme {
    static var defaultPointsBased: GradingScheme {
        PointsBasedGradingScheme.default
    }
}

#endif
