//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

/**
 The purpose of this property wrapper is to allow decoding of URLs from Strings with non url safe characters.
 The non-safe characters are percent encoded before decoding.
 This wrapper also threats empty string literal as nil instead of throwing an exception during parsing.
 */
@propertyWrapper
public struct SafeURL: Equatable {
    public var wrappedValue: URL?

    public init(wrappedValue: URL?) {
        self.wrappedValue = wrappedValue
    }
}

extension SafeURL: Encodable {

    public func encode(to encoder: Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension SafeURL: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)

        guard let safeURLString = stringValue.addingPercentEncoding(withAllowedCharacters: .urlSafe) else {
            wrappedValue = nil
            return
        }

        wrappedValue = URL(string: safeURLString)
    }
}

extension KeyedDecodingContainer {

    /**
     This is required because the default decode implementation for property wrappers throws an error in case the JSON key is missing for an optional wrapped value.
     We override the default implementation and handle the missing key manually.
     */
    func decode(_ type: SafeURL.Type, forKey key: Self.Key) throws -> SafeURL {
        try decodeIfPresent(type, forKey: key) ?? SafeURL(wrappedValue: nil)
    }
}
