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

public enum CodableValue {
    case string(String)
    case number(Double)
    case object([String: CodableValue])
    case array([CodableValue])
    case bool(Bool)
    case null
}

extension CodableValue: Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .array(array):
            try container.encode(array)
        case let .object(object):
            try container.encode(object)
        case let .string(string):
            try container.encode(string)
        case let .number(number):
            try container.encode(number)
        case let .bool(bool):
            try container.encode(bool)
        case .null:
            try container.encodeNil()
        }
    }
}

extension CodableValue: Decodable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let object = try? container.decode([String: CodableValue].self) {
            self = .object(object)
        } else if let array = try? container.decode([CodableValue].self) {
            self = .array(array)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let number = try? container.decode(Double.self) {
            self = .number(number)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.dataCorrupted(
                    .init(codingPath: decoder.codingPath, debugDescription: "Invalid value.")
            )
        }
    }
}

enum CodableValueError: Swift.Error {
    case decodingError
}

extension CodableValue {
    public init(_ value: Any?) throws {
        guard let value = value else { throw CodableValueError.decodingError }
        switch value {
        case let num as Double:
            self = .number(num)
        case let num as Int:
            self = .number(Double(num))
        case let str as String:
            self = .string(str)
        case let bool as Bool:
            self = .bool(bool)
        case let array as [Any]:
            self = .array(try array.map(CodableValue.init))
        case let dict as [String: Any]:
            self = .object(try dict.mapValues(CodableValue.init))
        default:
            throw CodableValueError.decodingError
        }
    }
}

extension CodableValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, Any)...) {
        var object: [String: CodableValue] = [:]
        for (k, v) in elements {
            if let v = try? CodableValue(v) {
                object[k] = v
            }
        }
        self = .object(object)
    }
}

extension CodableValue: CustomStringConvertible {
    public var description: String {
        switch self {
        case .string(let str):
            return str.description
        case .number(let num):
            return num.description
        case .bool(let bool):
            return bool.description
        case .null:
            return "null"
        default:
            return ""
        }
    }
}

