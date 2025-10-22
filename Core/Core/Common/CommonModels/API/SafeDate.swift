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

/// A property wrapper that gracefully handles malformed date strings during JSON decoding.
///
/// `JSONDecoder`'s `.iso8601` strategy is strict and rejects certain valid ISO8601 dates
/// (like negative years), causing the entire object to fail decoding. This wrapper uses `ISO8601DateFormatter`
/// directly, which is more lenient and allows such unlikely -but formatting-wise valid- dates to be parsed.
@propertyWrapper
public struct SafeDate: Codable, Equatable {
    public var wrappedValue: Date?

    private static let extendedFormatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    private static let standardFormatter = ISO8601DateFormatter()

    public init(wrappedValue: Date?) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // Handle explicit null values
        if container.decodeNil() {
            wrappedValue = nil
            return
        }

        // Try to decode the date string
        guard let dateString = try? container.decode(String.self) else {
            wrappedValue = nil
            return
        }

        // Handle empty strings
        if dateString.isEmpty {
            wrappedValue = nil
            return
        }

        // Try ISO8601 with fractional seconds first (for RN generated dates like "2019-06-02T18:07:28.000Z")
        // This must come BEFORE standard ISO8601 to avoid the extended formatter being too lenient
        if let date = Self.extendedFormatter.date(from: dateString) {
            wrappedValue = date
            return
        }

        // Try standard ISO8601 format (e.g., "2025-01-15T10:30:00Z" or "-3033-05-31T07:51:58Z")
        if let date = Self.standardFormatter.date(from: dateString) {
            wrappedValue = date
            return
        }

        // If date string is malformed and cannot be parsed, set to nil instead of crashing
        wrappedValue = nil
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let date = wrappedValue {
            try container.encode(date)
        } else {
            try container.encodeNil()
        }
    }
}
