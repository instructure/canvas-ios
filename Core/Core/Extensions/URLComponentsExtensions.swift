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

public extension URLComponents {
    /// Returns a URLComponents struct with properties copied from the URL.
    ///
    /// Unlike `init?(url: URL, resolvingAgainstBaseURL Bool)`, this never returns nil, though the components may not be convertable to a full URL.
    static func parse(_ url: URL) -> URLComponents {
        // Needed to handle mailto: & tel: links correctly.
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            return components
        }
        var components = URLComponents()
        components.scheme = url.scheme
        components.user = url.user
        components.percentEncodedPassword = url.password
        components.host = url.host
        components.port = url.port
        components.path = url.path
        components.percentEncodedQuery = url.query
        components.percentEncodedFragment = url.fragment
        return components
    }

    /// Returns a URLComponents struct parsed from the string.
    ///
    /// Tries `init(string: String)`, then again with aggressive percent encoding, then falls back to putting the string in a `path` property.
    static func parse(_ string: String) -> URLComponents {
        if let url = URLComponents(string: string) { return url }
        if let safe = string.addingPercentEncoding(withAllowedCharacters: .urlSafe),
            let url = URLComponents(string: safe) { return url }
        var url = URLComponents()
        url.path = string
        return url
    }

    var withCanonicalQueryParams: URLComponents {
        var cleaned = self
        cleaned.query = cleaned.query?.replacingOccurrences(of: "+", with: " ")
        cleaned.queryItems?.sort { a, b in
            String(describing: (a.name, a.value)) < String(describing: (b.name, b.value))
        }

        return cleaned
    }

    var originIsCalendar: Bool {
        if queryItems?.first(where: { $0.name == "origin" })?.value == "calendar" {
            return true
        }
        return false
    }

    var originIsModuleItemDetails: Bool {
        return queryItems?.first(where: { $0.name == "origin" })?.value == "module_item_details"
    }

    var originIsNotification: Bool {
        get {
            if let origin = queryItems?.first(where: { $0.name == "origin" })?.value, origin == "notification" {
                return true
            }
            return false
        }
        set {
            var qitems = queryItems ?? []
            if newValue {
                qitems.append( URLQueryItem(name: "origin", value: "notification") )
                queryItems = qitems
            } else {
                if var items = queryItems {
                    items.removeAll(where: { $0.name == "origin" && $0.value == "notification" })
                    queryItems = items
                }
            }
        }
    }
}

public extension CharacterSet {
    static let urlSafe = CharacterSet(charactersIn: ":/?&=#%.").union(.alphanumerics)
}
