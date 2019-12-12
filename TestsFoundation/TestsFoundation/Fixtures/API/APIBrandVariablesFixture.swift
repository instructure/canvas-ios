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

extension APIBrandVariables {
    public static func make(
        button_primary_bgd: String? = "#008EE2",
        button_primary_text: String? = "#ffffff",
        button_secondary_bgd: String? = "#2D3B45",
        button_secondary_text: String? = "#ffffff",
        font_color_dark: String? = "#2D3B45",
        header_image_bgd: String? = "#394B58",
        header_image: URL? = nil,
        link_color: String? = "#008EE2",
        nav_badge_bgd: String? = "#008EE2",
        nav_badge_text: String? = "#ffffff",
        nav_bgd: String? = "#394B58",
        nav_icon_fill: String? = "#ffffff",
        nav_icon_fill_active: String? = "#008EE2",
        nav_text_color: String? = "#ffffff",
        nav_text_color_active: String? = "#008EE2",
        primary: String? = "#008EE2"
    ) -> APIBrandVariables {
        return APIBrandVariables(
            button_primary_bgd: button_primary_bgd,
            button_primary_text: button_primary_text,
            button_secondary_bgd: button_secondary_bgd,
            button_secondary_text: button_secondary_text,
            font_color_dark: font_color_dark,
            header_image_bgd: header_image_bgd,
            header_image: header_image,
            link_color: link_color,
            nav_badge_bgd: nav_badge_bgd,
            nav_badge_text: nav_badge_text,
            nav_bgd: nav_bgd,
            nav_icon_fill: nav_icon_fill,
            nav_icon_fill_active: nav_icon_fill_active,
            nav_text_color: nav_text_color,
            nav_text_color_active: nav_text_color_active,
            primary: primary
        )
    }
}
