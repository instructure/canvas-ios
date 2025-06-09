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

import UIKit

public struct Brand: Equatable {

    public var headerImage: UIImage?
    public var institutionLogo: URL?

    public var buttonPrimaryBackground: UIColor {
        UIColor.getColor(dark: buttonPrimaryBackgroundDark, light: buttonPrimaryBackgroundLight)
    }
    public var buttonPrimaryText: UIColor {
        UIColor.getColor(dark: buttonPrimaryTextDark, light: buttonPrimaryTextLight)
    }
    public var buttonSecondaryBackground: UIColor {
        UIColor.getColor(dark: buttonSecondaryBackgroundDark, light: buttonSecondaryBackgroundLight)
    }
    public var buttonSecondaryText: UIColor {
        UIColor.getColor(dark: buttonSecondaryTextDark, light: buttonSecondaryTextLight)
    }
    public var fontColorDark: UIColor {
        UIColor.getColor(dark: fontColorDarkDark, light: fontColorDarkLight)
    }
    public var headerImageBackground: UIColor {
        UIColor.getColor(dark: headerImageBackgroundDark, light: headerImageBackgroundLight)
    }
    public var linkColor: UIColor {
        UIColor.getColor(dark: linkColorDark, light: linkColorLight)
    }
    public var navBackground: UIColor {
        UIColor.getColor(dark: navBackgroundDark, light: navBackgroundLight)
    }
    public var navBadgeBackground: UIColor {
        UIColor.getColor(dark: navBadgeBackgroundDark, light: navBadgeBackgroundLight)
    }
    public var navBadgeText: UIColor {
        UIColor.getColor(dark: navBadgeTextDark, light: navBadgeTextLight)
    }
    public var navIconFill: UIColor {
        UIColor.getColor(dark: navIconFillDark, light: navIconFillLight)
    }
    public var navIconFillActive: UIColor {
        UIColor.getColor(dark: navIconFillActiveDark, light: navIconFillActiveLight)
    }
    public var navTextColor: UIColor {
        UIColor.getColor(dark: navTextColorDark, light: navTextColorLight)
    }
    public var navTextColorActive: UIColor {
        UIColor.getColor(dark: navTextColorActiveDark, light: navTextColorActiveLight)
    }
    public var primary: UIColor {
        UIColor.getColor(dark: primaryDark, light: primaryLight)
    }
    public var tabBarHighlightColor: UIColor {
        primary.darkenToEnsureContrast(against: .backgroundLightest)
    }

    private var buttonPrimaryBackgroundDark: UIColor = .black
    private var buttonPrimaryTextDark: UIColor = .black
    private var buttonSecondaryBackgroundDark: UIColor = .black
    private var buttonSecondaryTextDark: UIColor = .black
    private var fontColorDarkDark: UIColor = .black
    private var headerImageBackgroundDark: UIColor = .black
    private var linkColorDark: UIColor = .black
    private var navBackgroundDark: UIColor = .black
    private var navBadgeBackgroundDark: UIColor = .black
    private var navBadgeTextDark: UIColor = .black
    private var navIconFillDark: UIColor = .black
    private var navIconFillActiveDark: UIColor = .black
    private var navTextColorDark: UIColor = .black
    private var navTextColorActiveDark: UIColor = .black
    private var primaryDark: UIColor = .black

    private var buttonPrimaryBackgroundLight: UIColor = .textLightest.variantForLightMode
    private var buttonPrimaryTextLight: UIColor = .textLightest.variantForLightMode
    private var buttonSecondaryBackgroundLight: UIColor = .textLightest.variantForLightMode
    private var buttonSecondaryTextLight: UIColor = .textLightest.variantForLightMode
    private var fontColorDarkLight: UIColor = .textLightest.variantForLightMode
    private var headerImageBackgroundLight: UIColor = .textLightest.variantForLightMode
    private var linkColorLight: UIColor = .textLightest.variantForLightMode
    private var navBackgroundLight: UIColor = .textLightest.variantForLightMode
    private var navBadgeBackgroundLight: UIColor = .textLightest.variantForLightMode
    private var navBadgeTextLight: UIColor = .textLightest.variantForLightMode
    private var navIconFillLight: UIColor = .textLightest.variantForLightMode
    private var navIconFillActiveLight: UIColor = .textLightest.variantForLightMode
    private var navTextColorLight: UIColor = .textLightest.variantForLightMode
    private var navTextColorActiveLight: UIColor = .textLightest.variantForLightMode
    private var primaryLight: UIColor = .textLightest.variantForLightMode

    public init(
        buttonPrimaryBackground: UIColor?,
        buttonPrimaryText: UIColor?,
        buttonSecondaryBackground: UIColor?,
        buttonSecondaryText: UIColor?,
        fontColorDark: UIColor?,
        headerImageBackground: UIColor?,
        headerImage: UIImage?,
        linkColor: UIColor?,
        navBackground: UIColor?,
        navBadgeBackground: UIColor?,
        navBadgeText: UIColor?,
        navIconFill: UIColor?,
        navIconFillActive: UIColor?,
        navTextColor: UIColor?,
        navTextColorActive: UIColor?,
        primary: UIColor?,
        institutionLogo: URL?
    ) {
        self.headerImage = headerImage ?? UIImage(named: "defaultHeaderImage", in: .core, compatibleWith: nil)
        self.institutionLogo = institutionLogo
        self.buttonPrimaryBackgroundLight = buttonPrimaryBackground ?? .backgroundInfo
        self.buttonPrimaryTextLight = buttonPrimaryText != nil ? buttonPrimaryText!.ensureContrast(against: self.buttonPrimaryBackgroundLight) : .textLightest.variantForLightMode
        self.buttonSecondaryBackgroundLight = buttonSecondaryBackground ?? .backgroundDarkest
        self.buttonSecondaryTextLight = buttonSecondaryText != nil ? buttonSecondaryText!.ensureContrast(against: self.buttonSecondaryBackgroundLight) : .textLightest.variantForLightMode
        self.fontColorDarkLight = fontColorDark ?? .textDarkest
        self.headerImageBackgroundLight = headerImageBackground ?? .backgroundDarkest
        self.linkColorLight = linkColor ?? .textInfo
        self.navBackgroundLight = navBackground ?? .backgroundDarkest
        self.navBadgeBackgroundLight = navBadgeBackground ?? .backgroundInfo
        self.navBadgeTextLight = navBadgeText ?? .textLightest.variantForLightMode
        self.navIconFillLight = navIconFill ?? .textLightest.variantForLightMode
        self.navIconFillActiveLight = navIconFillActive ?? .backgroundInfo
        self.navTextColorLight = navTextColor != nil ? navTextColor!.ensureContrast(against: navBackgroundLight) : .textLightest.variantForLightMode
        self.navTextColorActiveLight = navTextColorActive ?? .textInfo
        self.primaryLight = primary ?? .textInfo

        self.buttonPrimaryBackgroundDark = buttonPrimaryBackground != nil ? buttonPrimaryBackground!.ensureContrast(against: .backgroundLightest) : .backgroundInfo
        self.buttonPrimaryTextDark = buttonPrimaryText != nil ? buttonPrimaryText!.ensureContrast(against: self.buttonPrimaryBackgroundDark) : .textLightest.variantForLightMode
        self.buttonSecondaryBackgroundDark = buttonSecondaryBackground != nil ? buttonSecondaryBackground!.ensureContrast(against: .backgroundLightest) : .backgroundDarkest
        self.buttonSecondaryTextDark = buttonSecondaryText != nil ? buttonSecondaryText!.ensureContrast(against: self.buttonSecondaryBackgroundDark) : .textLightest.variantForLightMode
        self.fontColorDarkDark = fontColorDark != nil ? fontColorDark!.ensureContrast(against: .backgroundLightest) : .textDarkest
        self.headerImageBackgroundDark = headerImageBackground ?? .backgroundDarkest.variantForLightMode
        self.linkColorDark = linkColor != nil ? linkColor!.ensureContrast(against: .backgroundLightest) : .textInfo
        self.navBackgroundDark = navBackground ?? .backgroundDarkest.variantForLightMode
        self.navBadgeBackgroundDark = navBadgeBackground != nil ? navBadgeBackground!.ensureContrast(against: self.navBackgroundDark) : .backgroundInfo
        self.navBadgeTextDark = navBadgeText != nil ? navBadgeText!.ensureContrast(against: self.navBadgeBackgroundDark) : .textLightest.variantForLightMode
        self.navIconFillDark = navIconFill != nil ? navIconFill!.ensureContrast(against: self.navBackgroundDark) : .textLightest.variantForLightMode
        self.navIconFillActiveDark = navIconFillActive != nil ? navIconFillActive!.ensureContrast(against: self.navBackgroundDark) : .backgroundInfo
        self.navTextColorDark = navTextColor != nil ? navTextColor!.ensureContrast(against: self.navBackgroundDark) : .textLightest.variantForLightMode
        self.navTextColorActiveDark = navTextColorActive != nil ? navTextColorActive!.ensureContrast(against: self.navBackgroundDark) : .textInfo
        self.primaryDark = primary != nil ? primary!.ensureContrast(against: .backgroundLightest) : .textInfo
    }

    public init(
        response: APIBrandVariables,
        headerImage: UIImage?,
        institutionLogo: URL?
    ) {
        self.init(
            buttonPrimaryBackground: UIColor(hexString: response.button_primary_bgd),
            buttonPrimaryText: UIColor(hexString: response.button_primary_text),
            buttonSecondaryBackground: UIColor(hexString: response.button_secondary_bgd),
            buttonSecondaryText: UIColor(hexString: response.button_secondary_text),
            fontColorDark: UIColor(hexString: response.font_color_dark),
            headerImageBackground: UIColor(hexString: response.header_image_bgd),
            headerImage: headerImage,
            linkColor: UIColor(hexString: response.link_color),
            navBackground: UIColor(hexString: response.nav_bgd),
            navBadgeBackground: UIColor(hexString: response.nav_badge_bgd),
            navBadgeText: UIColor(hexString: response.nav_badge_text),
            navIconFill: UIColor(hexString: response.nav_icon_fill),
            navIconFillActive: UIColor(hexString: response.nav_icon_fill_active),
            navTextColor: UIColor(hexString: response.nav_text_color),
            navTextColorActive: UIColor(hexString: response.nav_text_color_active),
            primary: UIColor(hexString: response.primary),
            institutionLogo: institutionLogo
        )
    }

    public static var shared = Brand(
        buttonPrimaryBackground: nil,
        buttonPrimaryText: nil,
        buttonSecondaryBackground: nil,
        buttonSecondaryText: nil,
        fontColorDark: nil,
        headerImageBackground: nil,
        headerImage: nil,
        linkColor: nil,
        navBackground: nil,
        navBadgeBackground: nil,
        navBadgeText: nil,
        navIconFill: nil,
        navIconFillActive: nil,
        navTextColor: nil,
        navTextColorActive: nil,
        primary: nil,
        institutionLogo: nil
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
            return UIColor(named: name, in: .core, compatibleWith: nil)
        }
    }

    public func headerImageView() -> UIImageView {
        let logoView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        logoView.contentMode = .scaleAspectFit
        logoView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        logoView.image = headerImage
        logoView.backgroundColor = headerImageBackground
        logoView.accessibilityElementsHidden = true
        return logoView
    }
}
