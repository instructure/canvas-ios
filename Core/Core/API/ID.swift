//
// This file is part of Canvas.
// Copyright (C) 2018-present  Instructure, Inc.
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

//  swiftlint:disable type_name
public struct ID: Codable, Equatable, Hashable, CustomStringConvertible, RawRepresentable {
//  swiftlint:enable type_name
    public typealias RawValue = String

    public let value: String
    public var rawValue: String { value }
    public var description: String { value }

    public init(from decoder: Decoder) throws {
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            value = String(int)
            return
        }

        if let string = try? decoder.singleValueContainer().decode(String.self) {
            value = ID.expandTildeID(string)
            return
        }

        value = ""
    }

    public init(_ string: String) {
        self.init(stringLiteral: string)
    }

    public init(rawValue: String) {
        self.init(stringLiteral: rawValue)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if value.isEmpty {
            try container.encodeNil()
        } else {
            try container.encode(value)
        }
    }

    enum IDError: Error {
        case missingValue
    }

    public static func expandTildeID(_ id: String) -> String {
        let parts: [String] = id.components(separatedBy: "~")
        if parts.count == 2, let shardID = Int64(parts[0]), let resourceID = Int64(parts[1]) {
            let shardFactor: Int64 = 10_000_000_000_000
            return (Decimal(shardID) * Decimal(shardFactor) + Decimal(resourceID)).description
        }
        return id
    }
}

extension ID: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.value = ID.expandTildeID(value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(stringLiteral: value)
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(stringLiteral: value)
    }
}

extension ID: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        self.value = String(value)
    }
}
