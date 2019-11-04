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

extension URLResponse {
    var links: [String: URL]? {
        guard let header = (self as? HTTPURLResponse)?.allHeaderFields["Link"] as? String else { return nil }
        var links: [String: URL] = [:]
        for link in header.split(separator: ",") {
            let parts = link.split(separator: ";").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
            guard
                let first = parts.first, first.hasPrefix("<"), first.hasSuffix(">"),
                let url = URL(string: first.trimmingCharacters(in: CharacterSet(charactersIn: "<>")))
            else { continue }

            for part in parts.dropFirst() {
                let pair = part.split(separator: "=").map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
                let value = pair.last?.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                if pair.first == "rel", let rel = value {
                    links[rel] = url
                }
            }
        }
        return links
    }

    public var isUnauthorized: Bool {
        return (self as? HTTPURLResponse)?.statusCode == 401
    }
}

extension HTTPURLResponse {
    public convenience init(next: String) {
        let headers = [
            "Link": "<\(next)>; rel=\"next\"; count=1",
        ]
        self.init(url: URL(string: "/")!, statusCode: 200, httpVersion: "HTTP/1.1", headerFields: headers)!
    }
}
