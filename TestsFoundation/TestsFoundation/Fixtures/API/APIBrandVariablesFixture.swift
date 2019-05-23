//
// Copyright (C) 2018-present Instructure, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
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
        header_image: URL? = URL(string: "https://instructure-uploads.s3.amazonaws.com/account_70000000000010/attachments/64473710/canvas_logomark_only2x.png"),
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
