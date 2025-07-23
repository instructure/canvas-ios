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

// https://canvas.instructure.com/doc/api/brand_configs.html
public struct APIBrandVariables: Codable, Equatable {
    let button_primary_bgd: String?
    let button_primary_text: String?
    let button_secondary_bgd: String?
    let button_secondary_text: String?
    let font_color_dark: String?
    let header_image_bgd: String?
    let header_image: URL?
    let link_color: String?
    let nav_badge_bgd: String?
    let nav_badge_text: String?
    let nav_bgd: String?
    let nav_icon_fill: String?
    let nav_icon_fill_active: String?
    let nav_text_color: String?
    let nav_text_color_active: String?
    let primary: String?
    let institutionLogo: URL?

    enum CodingKeys: String, CodingKey {
        case button_primary_bgd = "ic-brand-button--primary-bgd"
        case button_primary_text = "ic-brand-button--primary-text"
        case button_secondary_bgd = "ic-brand-button--secondary-bgd"
        case button_secondary_text = "ic-brand-button--secondary-text"
        case font_color_dark = "ic-brand-font-color-dark"
        case header_image = "ic-brand-header-image"
        case header_image_bgd = "ic-brand-global-nav-logo-bgd"
        case link_color = "ic-link-color"
        case nav_badge_bgd = "ic-brand-global-nav-menu-item__badge-bgd"
        case nav_badge_text = "ic-brand-global-nav-menu-item__badge-text"
        case nav_bgd = "ic-brand-global-nav-bgd"
        case nav_icon_fill = "ic-brand-global-nav-ic-icon-svg-fill"
        case nav_icon_fill_active = "ic-brand-global-nav-ic-icon-svg-fill--active"
        case nav_text_color = "ic-brand-global-nav-menu-item__text-color"
        case nav_text_color_active = "ic-brand-global-nav-menu-item__text-color--active"
        case primary = "ic-brand-primary"
        case institutionLogo = "ic-brand-mobile-global-nav-logo"
    }
}

#if DEBUG
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
            primary: primary,
            institutionLogo: nil
        )
    }
}
#endif

// https://canvas.instructure.com/doc/api/brand_configs.html#method.brand_configs_api.show
public struct GetBrandVariablesRequest: APIRequestable {
    public typealias Response = APIBrandVariables

    public let path = "brand_variables"
    public let headers: [String: String?] = [
        HttpHeader.authorization: nil
    ]
}
