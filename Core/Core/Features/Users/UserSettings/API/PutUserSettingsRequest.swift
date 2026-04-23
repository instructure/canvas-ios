//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

// https://canvas.instructure.com/doc/api/users.html#method.users.settings
public struct PutUserSettingsRequest: APIRequestable {
    public typealias Response = APIUserSettings
    public struct Body: Encodable {
        let manual_mark_as_read: Bool?
        let collapse_global_nav: Bool?
        let hide_dashcard_color_overlays: Bool?
        let comment_library_suggestions_enabled: Bool?
    }

    public let method = APIMethod.put
    public let path = "users/self/settings"
    public let body: Body?

    init(manual_mark_as_read: Bool? = nil, collapse_global_nav: Bool? = nil, hide_dashcard_color_overlays: Bool? = nil, comment_library_suggestions_enabled: Bool? = nil) {
        body = Body(
            manual_mark_as_read: manual_mark_as_read,
            collapse_global_nav: collapse_global_nav,
            hide_dashcard_color_overlays: hide_dashcard_color_overlays,
            comment_library_suggestions_enabled: comment_library_suggestions_enabled
        )
    }
}
