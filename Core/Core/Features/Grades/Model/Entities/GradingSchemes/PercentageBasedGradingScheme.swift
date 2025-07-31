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

    /// converts 0.1234 -> "12.34%", 0.42 -> "42%"
    private static let percentFormatter = GradeFormatter.percentFormatter

    public let entries: [GradingSchemeEntry]

    public init(entries: [GradingSchemeEntry]) {
        self.entries = entries
    }

    public var maxFormattedValue: String? {
        Self.percentFormatter.string(from: NSNumber(value: 1))
    }

    public func formattedEntryValue(_ value: Double) -> String? {
        Self.percentFormatter.string(from: NSNumber(value: value))
    }

    public func formattedScore(from value: Double) -> String? {
        Self.percentFormatter.string(from: NSNumber(value: value))
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
