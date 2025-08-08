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

    private static let numberFormatter = GradeFormatter.numberFormatter

    public let entries: [GradingSchemeEntry]
    private let scaleFactor: Double

    public init(entries: [GradingSchemeEntry], scaleFactor: Double) {
        self.entries = entries
        self.scaleFactor = scaleFactor
    }

    public var formattedMaxValue: String? {
        Self.numberFormatter.string(from: NSNumber(value: scaleFactor))
    }

    // Expects GradingSchemeEntry values which are in range of [0,1]
    public func formattedEntryValue(_ value: Double) -> String? {
        // Scaling it up, for example 0.75 to 3 (when max value is 4)
        let scaledValue = value * scaleFactor
        return Self.numberFormatter.string(from: NSNumber(value: scaledValue))
    }

    public func formattedScore(from value: Double) -> String? {
        let normalizedScore = value / 100.0
        let number = NSNumber(value: normalizedScore * scaleFactor)
        return Self.numberFormatter.string(from: number)
    }
}

// MARK: - Schemes for Previews & Testing

#if DEBUG

public extension PointsBasedGradingScheme {
    static var `default`: Self {
        PointsBasedGradingScheme(entries: [], scaleFactor: 4)
    }
}

public extension GradingScheme where Self == PointsBasedGradingScheme {
    static var defaultPointsBased: GradingScheme {
        PointsBasedGradingScheme.default
    }
}

#endif
