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

public struct APIUserSettings: Codable, Equatable {
    let manual_mark_as_read: Bool
    let collapse_global_nav: Bool
    let hide_dashcard_color_overlays: Bool
    let comment_library_suggestions_enabled: Bool
}

#if DEBUG

extension APIUserSettings {
    public static func make(
        manual_mark_as_read: Bool = false,
        collapse_global_nav: Bool = false,
        hide_dashcard_color_overlays: Bool = false,
        comment_library_suggestions_enabled: Bool = false
    ) -> APIUserSettings {
        APIUserSettings(
            manual_mark_as_read: manual_mark_as_read,
            collapse_global_nav: collapse_global_nav,
            hide_dashcard_color_overlays: hide_dashcard_color_overlays,
            comment_library_suggestions_enabled: comment_library_suggestions_enabled
        )
    }
}

#endif
