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
}
