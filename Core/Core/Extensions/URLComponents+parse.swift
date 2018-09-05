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

public extension URLComponents {
    /// Returns a URLComponents struct with properties copied from the URL.
    ///
    /// Unlike `init?(url: URL, resolvingAgainstBaseURL Bool)`, this never returns nil, though the components may not be convertable to a full URL.
    public static func parse(_ url: URL) -> URLComponents {
        var components = URLComponents()
        components.scheme = url.scheme
        components.user = url.user
        components.password = url.password
        components.host = url.host
        components.port = url.port
        components.path = url.path
        components.query = url.query
        components.fragment = url.fragment
        return components
    }

    /// Returns a URLComponents struct parsed from the string.
    ///
    /// Tries `init(string: String)`, then again with aggressive percent encoding, then falls back to putting the string in a `path` property.
    public static func parse(_ string: String) -> URLComponents {
        if let url = URLComponents(string: string) { return url }
        if let safe = string.addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: ":/?&=#%").union(.alphanumerics)),
            let url = URLComponents(string: safe) { return url }
        var url = URLComponents()
        url.path = string
        return url
    }
}
