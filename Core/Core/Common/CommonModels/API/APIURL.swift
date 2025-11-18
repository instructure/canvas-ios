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
        let string = try container.decode(String.self)
            .removingXMLEscaping
            .fixingBracketsPercentEncoding
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

    public func decodeIfPresent(_ type: APIURL.Type, forKey key: Self.Key) throws -> APIURL? {
        try decodeURLIfPresent(forKey: key)
    }
}

private extension String {

    var hasPercentEncoding: Bool {
        let decoded = removingPercentEncoding ?? self
        return decoded != self
    }

    /// This is fix string with already percent-encoded query except for
    /// brackets characters `[` & `]`. This is to avoid double percent-encoding
    /// for an already encoded characters when fed to `URL.init(string:)`,
    /// leading to failure on request.
    var fixingBracketsPercentEncoding: String {
        guard hasPercentEncoding else { return self }

        var value = self
        ["[", "]"].forEach { char in
            if let encoded = char.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                value = value.replacingOccurrences(of: char, with: encoded)
            }
        }

        return value
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
