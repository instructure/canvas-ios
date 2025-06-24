//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Core

extension URL {

    static var appEmptyRoute: URL {
        appRoute("")
    }

    static func appRoute(_ path: String) -> URL {
        var urlComps = URLComponents()
        urlComps.scheme = "canvas-courses"
        urlComps.host = AppEnvironment.shared.currentSession?.baseURL.host
        urlComps.path = "/" + path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        return urlComps.url ?? URL(filePath: "/")
    }

    static func todoWidgetRoute(_ path: String) -> URL {
        appRoute(path).appendingOrigin("todo-widget")
    }

    static func gradesListWidgetRoute(_ path: String) -> URL {
        appRoute(path).appendingOrigin("grades-list-widget")
    }
}
