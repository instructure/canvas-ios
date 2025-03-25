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

public protocol GradingScheme {
    var entries: [GradingSchemeEntry] { get }

    func convertScoreToLetterGrade(score: Double) -> String?
    func formattedScore(from value: Double) -> String?
}

public extension GradingScheme {

    func convertScoreToLetterGrade(score: Double) -> String? {
        let normalizedScore = score / 100.0
        return entries.first { normalizedScore >= $0.value }?.name
    }
}

public struct PercentageBasedGradingScheme: GradingScheme {

    public let entries: [GradingSchemeEntry]

    fileprivate init(entries: [GradingSchemeEntry]) {
        self.entries = entries
    }

    public func formattedScore(from value: Double) -> String? {
        Self.percentFormatter.string(from: NSNumber(value: value))
    }

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

public struct PointsBasedGradingScheme: GradingScheme {

    public let scaleFactor: Double
    public let entries: [GradingSchemeEntry]

    fileprivate init(scaleFactor: Double, entries: [GradingSchemeEntry]) {
        self.scaleFactor = scaleFactor
        self.entries = entries
    }

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

public extension PercentageBasedGradingScheme {
    static var `default`: Self {
        PercentageBasedGradingScheme(entries: [])
    }

    static func make(entries: [GradingSchemeEntry]) -> Self {
        PercentageBasedGradingScheme(entries: entries)
    }
}

public extension PointsBasedGradingScheme {
    static var `default`: Self {
        PointsBasedGradingScheme(scaleFactor: 4, entries: [])
    }

    static func make(scaleFactor: Double, entries: [GradingSchemeEntry]) -> Self {
        PointsBasedGradingScheme(scaleFactor: scaleFactor, entries: entries)
    }
}

public extension GradingScheme where Self == PercentageBasedGradingScheme {
    static var defaultPercentageBased: GradingScheme {
        PercentageBasedGradingScheme.default
    }
}

public extension GradingScheme where Self == PointsBasedGradingScheme {
    static var defaultPointsBased: GradingScheme {
        PointsBasedGradingScheme.default
    }
}

#endif

// MARK: - As Course's property

extension Course {

    public var gradingScheme: GradingScheme {
        if pointsBasedGradingScheme {
            return PointsBasedGradingScheme(scaleFactor: scalingFactor, entries: gradingSchemeEntries)
        } else {
            return PercentageBasedGradingScheme(entries: gradingSchemeEntries)
        }
    }
}
