//
// This file is part of Canvas.
// Copyright (C) 2019-present  Instructure, Inc.
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

public struct APIURL: Codable, Equatable {
    public let rawValue: URL

    public init(rawValue: URL) {
        self.rawValue = rawValue
    }

    public init?(rawValue: URL?) {
        guard let rawValue = rawValue else { return nil }
        self.rawValue = rawValue
    }

    public init(from decoder: Decoder) throws {
        let baseURL = AppEnvironment.shared.currentSession?.baseURL
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self).removingXMLEscaping
        if let url = URL(string: string, relativeTo: baseURL) {
            rawValue = url
            return
        }
        if let safe = string.addingPercentEncoding(withAllowedCharacters: .urlSafe), let url = URL(string: safe, relativeTo: baseURL) {
            rawValue = url
            return
        }
        let context = DecodingError.Context(
            codingPath: decoder.codingPath,
            debugDescription: "Expected a valid URL"
        )
        throw DecodingError.typeMismatch(URL.self, context)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension KeyedDecodingContainer {
    public func decodeURLIfPresent(forKey key: Self.Key) throws -> APIURL? {
        let rawValue = try decodeIfPresent(String.self, forKey: key)
        if rawValue?.isEmpty == false {
            return try decode(APIURL.self, forKey: key)
        }
        return nil
    }
}

#if DEBUG
extension APIURL {
    public static func make(
        rawValue: URL = URL(string: "https://canvas.instructure.com")!
    ) -> APIURL {
        return APIURL(rawValue: rawValue)
    }
}
#endif
