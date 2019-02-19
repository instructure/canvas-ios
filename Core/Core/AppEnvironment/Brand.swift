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

import UIKit

public struct Brand: Equatable {
    public let buttonPrimaryBackground: UIColor
    public let buttonPrimaryText: UIColor
    public let buttonSecondaryBackground: UIColor
    public let buttonSecondaryText: UIColor
    public let fontColorDark: UIColor
    public let headerImageBackground: UIColor
    public let headerImageUrl: URL?
    public let linkColor: UIColor
    public let navBackground: UIColor
    public let navBadgeBackground: UIColor
    public let navBadgeText: UIColor
    public let navIconFill: UIColor
    public let navIconFillActive: UIColor
    public let navTextColor: UIColor
    public let navTextColorActive: UIColor
    public let primary: UIColor

    public init(
        buttonPrimaryBackground: UIColor?,
        buttonPrimaryText: UIColor?,
        buttonSecondaryBackground: UIColor?,
        buttonSecondaryText: UIColor?,
        fontColorDark: UIColor?,
        headerImageBackground: UIColor?,
        headerImageUrl: URL?,
        linkColor: UIColor?,
        navBackground: UIColor?,
        navBadgeBackground: UIColor?,
        navBadgeText: UIColor?,
        navIconFill: UIColor?,
        navIconFillActive: UIColor?,
        navTextColor: UIColor?,
        navTextColorActive: UIColor?,
        primary: UIColor?
    ) {
        self.buttonPrimaryBackground = buttonPrimaryBackground ?? .named(.electric)
        self.buttonPrimaryText = buttonPrimaryText ?? .named(.white)
        self.buttonSecondaryBackground = buttonSecondaryBackground ?? .named(.licorice)
        self.buttonSecondaryText = buttonSecondaryText ?? .named(.white)
        self.fontColorDark = fontColorDark ?? .named(.licorice)
        self.headerImageBackground = headerImageBackground ?? .named(.oxford)
        self.headerImageUrl = headerImageUrl ?? Bundle.core.url(forResource: "defaultHeaderImage", withExtension: "png")
        self.linkColor = linkColor ?? .named(.electric)
        self.navBackground = navBackground ?? .named(.oxford)
        self.navBadgeBackground = navBadgeBackground ?? .named(.electric)
        self.navBadgeText = navBadgeText ?? .named(.white)
        self.navIconFill = navIconFill ?? .named(.white)
        self.navIconFillActive = navIconFillActive ?? .named(.electric)
        self.navTextColor = navTextColor ?? .named(.white)
        self.navTextColorActive = navTextColorActive ?? .named(.electric)
        self.primary = primary ?? .named(.electric)
    }

    public init(response: APIBrandVariables) {
        self.init(
            buttonPrimaryBackground: UIColor(hexString: response.button_primary_bgd),
            buttonPrimaryText: UIColor(hexString: response.button_primary_text),
            buttonSecondaryBackground: UIColor(hexString: response.button_secondary_bgd),
            buttonSecondaryText: UIColor(hexString: response.button_secondary_text),
            fontColorDark: UIColor(hexString: response.font_color_dark),
            headerImageBackground: UIColor(hexString: response.header_image_bgd),
            headerImageUrl: response.header_image,
            linkColor: UIColor(hexString: response.link_color),
            navBackground: UIColor(hexString: response.nav_bgd),
            navBadgeBackground: UIColor(hexString: response.nav_badge_bgd),
            navBadgeText: UIColor(hexString: response.nav_badge_text),
            navIconFill: UIColor(hexString: response.nav_icon_fill),
            navIconFillActive: UIColor(hexString: response.nav_icon_fill_active),
            navTextColor: UIColor(hexString: response.nav_text_color),
            navTextColorActive: UIColor(hexString: response.nav_text_color_active),
            primary: UIColor(hexString: response.primary)
        )
    }

    public static var shared = Brand(
        buttonPrimaryBackground: nil,
        buttonPrimaryText: nil,
        buttonSecondaryBackground: nil,
        buttonSecondaryText: nil,
        fontColorDark: nil,
        headerImageBackground: nil,
        headerImageUrl: nil,
        linkColor: nil,
        navBackground: nil,
        navBadgeBackground: nil,
        navBadgeText: nil,
        navIconFill: nil,
        navIconFillActive: nil,
        navTextColor: nil,
        navTextColorActive: nil,
        primary: nil
    )

    public func color(_ name: String) -> UIColor? {
        switch name {
        case "buttonPrimaryBackground":
            return buttonPrimaryBackground
        case "buttonPrimaryText":
            return buttonPrimaryText
        case "buttonSecondaryBackground":
            return buttonSecondaryBackground
        case "buttonSecondaryText":
            return buttonSecondaryText
        case "fontColorDark":
            return fontColorDark
        case "headerImageBackground":
            return headerImageBackground
        case "linkColor":
            return linkColor
        case "navBackground":
            return navBackground
        case "navBadgeBackground":
            return navBadgeBackground
        case "navBadgeText":
            return navBadgeText
        case "navIconFill":
            return navIconFill
        case "navIconFillActive":
            return navIconFillActive
        case "navTextColor":
            return navTextColor
        case "navTextColorActive":
            return navTextColorActive
        case "primary":
            return primary
        default:
            return UIColor.Name(rawValue: name).flatMap { UIColor.named($0) }
        }
    }
}
