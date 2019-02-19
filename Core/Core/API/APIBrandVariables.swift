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

// https://canvas.instructure.com/doc/api/brand_configs.html
public struct APIBrandVariables: Codable, Equatable {
    let button_primary_bgd: String
    let button_primary_text: String
    let button_secondary_bgd: String
    let button_secondary_text: String
    let font_color_dark: String
    let header_image_bgd: String
    let header_image: URL?
    let link_color: String
    let nav_badge_bgd: String
    let nav_badge_text: String
    let nav_bgd: String
    let nav_icon_fill: String
    let nav_icon_fill_active: String
    let nav_text_color: String
    let nav_text_color_active: String
    let primary: String

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
    }
}
