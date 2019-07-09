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
@testable import Core

extension APIUser {
    public static func make(
        id: ID = "1",
        name: String = "Bob",
        sortable_name: String = "Bob",
        short_name: String = "Bob",
        login_id: String? = nil,
        avatar_url: URL? = nil,
        email: String? = nil,
        locale: String? = "en",
        effective_locale: String? = nil,
        bio: String? = nil
    ) -> APIUser {
        return APIUser(
            id: id,
            name: name,
            sortable_name: sortable_name,
            short_name: short_name,
            login_id: login_id,
            avatar_url: avatar_url,
            email: email,
            locale: locale,
            effective_locale: effective_locale,
            bio: bio
        )
    }
}

extension APIUser: APIContext {
    public var contextType: ContextType { return .user }
}

extension APIUserSettings {
    public static func make(
        manual_mark_as_read: Bool = false,
        collapse_global_nav: Bool = false,
        hide_dashcard_color_overlays: Bool = false
    ) -> APIUserSettings {
        return APIUserSettings(
            manual_mark_as_read: manual_mark_as_read,
            collapse_global_nav: collapse_global_nav,
            hide_dashcard_color_overlays: hide_dashcard_color_overlays
        )
    }
}
