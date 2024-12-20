//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

public typealias CodableEquatable = Codable & Equatable

/**
 The purpose of this entity is to allow two different data types to be coded/decoded to/from a single entity. Useful if a JSON property has different data types based on the context.
 Example: `APIPlannable`'s `submissions` property can be either a `Bool` or a custom structure depending on if the plannable is an announcement or an assignment.
 */
public struct TypeSafeCodable<T1: CodableEquatable, T2: CodableEquatable>: CodableEquatable {
    public let value1: T1?
    public let value2: T2?

    public init(value1: T1?, value2: T2?) {
        self.value1 = value1
        self.value2 = value2
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let type1Value = try? container.decode(T1.self) {
            value1 = type1Value
            value2 = nil

        } else if let type2Value = try? container.decode(T2.self) {
            value1 = nil
            value2 = type2Value

        } else {
            value1 = nil
            value2 = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        var singleEncoder = encoder.singleValueContainer()

        if let value1 = value1 {
            try singleEncoder.encode(value1)

        } else if let value2 = value2 {
            try singleEncoder.encode(value2)

        } else {
            try singleEncoder.encodeNil()
        }
    }
}
