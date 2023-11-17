//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

import WebKit

private class SkipJSInjection: CoreWebViewFeature {
    fileprivate let js: String

    public init(_ js: String) {
        self.js = js
    }
}

public extension CoreWebViewFeature {

    static func skipJSInjection(_ js: String) -> CoreWebViewFeature {
        SkipJSInjection(js)
    }
}

public extension Array where Element == CoreWebViewFeature {

    func shouldInjectJS(_ js: String) -> Bool {
        !contains { feature in
            guard let skipJS = feature as? SkipJSInjection else {
                return false
            }

            return skipJS.js == js
        }
    }
}
