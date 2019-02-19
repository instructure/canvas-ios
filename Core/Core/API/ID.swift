//
// Copyright (C) 2018-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import Foundation

//  swiftlint:disable type_name
struct ID: Codable, Equatable, CustomStringConvertible {
//  swiftlint:enable type_name

    let value: String
    var description: String {
        return value
    }

    init(from decoder: Decoder) throws {
        if let int = try? decoder.singleValueContainer().decode(Int.self) {
            value = String(int)
            return
        }

        if let string = try? decoder.singleValueContainer().decode(String.self) {
            value = string
            return
        }

        value = ""
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
}

extension ID: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.value = value
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
