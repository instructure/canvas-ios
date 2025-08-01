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

public struct PercentageBasedGradingScheme: GradingScheme {

    private static let percentFormatter = GradeFormatter.percentFormatter

    public let entries: [GradingSchemeEntry]

    public init(entries: [GradingSchemeEntry]) {
        self.entries = entries
    }

    public var formattedMaxValue: String? {
        Self.percentFormatter.string(from: NSNumber(value: 1))
    }

    // Expects GradingSchemeEntry values which are in range of [0,1]
    public func formattedEntryValue(_ entryValue: Double) -> String? {
        // Not scaling them up, because percentFormatter expects the same range. For example it converts 0.42 to "42%"
        Self.percentFormatter.string(from: NSNumber(value: entryValue))
    }

    // Expects scores which are in range of [0,100+]
    public func formattedScore(from score: Double) -> String? {
        let normalizedScore = score / 100.0
        return Self.percentFormatter.string(from: NSNumber(value: normalizedScore))
    }
}

// MARK: - Schemes for Previews & Testing

#if DEBUG

public extension PercentageBasedGradingScheme {
    static var `default`: Self {
        PercentageBasedGradingScheme(entries: [])
    }
}

public extension GradingScheme where Self == PercentageBasedGradingScheme {
    static var defaultPercentageBased: GradingScheme {
        PercentageBasedGradingScheme.default
    }
}

#endif
