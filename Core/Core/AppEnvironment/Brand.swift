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
    public let headerImageUrl: URL?
    public let linkColor: UIColor
    public let navBackground: UIColor
    public let navIconFill: UIColor
    public let navTextColor: UIColor
    public let primary: UIColor

    public init(
        buttonPrimaryBackground: UIColor?,
        buttonPrimaryText: UIColor?,
        buttonSecondaryBackground: UIColor?,
        buttonSecondaryText: UIColor?,
        fontColorDark: UIColor?,
        headerImageUrl: URL?,
        linkColor: UIColor?,
        navBackground: UIColor?,
        navIconFill: UIColor?,
        navTextColor: UIColor?,
        primary: UIColor?
    ) {
        self.buttonPrimaryBackground = buttonPrimaryBackground ?? .named(.electric)
        self.buttonPrimaryText = buttonPrimaryText ?? .named(.white)
        self.buttonSecondaryBackground = buttonSecondaryBackground ?? .named(.oxford)
        self.buttonSecondaryText = buttonSecondaryText ?? .named(.white)
        self.fontColorDark = fontColorDark ?? .named(.textDarkest)
        self.headerImageUrl = headerImageUrl ?? Bundle.core.url(forResource: "defaultHeaderImage", withExtension: "png")
        self.linkColor = linkColor ?? .named(.electric)
        self.navBackground = navBackground ?? .named(.oxford)
        self.navIconFill = navIconFill ?? .named(.white)
        self.navTextColor = navTextColor ?? .named(.white)
        self.primary = primary ?? .named(.electric)
    }

    public static var shared = Brand(
        buttonPrimaryBackground: nil,
        buttonPrimaryText: nil,
        buttonSecondaryBackground: nil,
        buttonSecondaryText: nil,
        fontColorDark: nil,
        headerImageUrl: nil,
        linkColor: nil,
        navBackground: nil,
        navIconFill: nil,
        navTextColor: nil,
        primary: nil
    )

    public func apply(to window: UIWindow) {
        window.tintColor = buttonPrimaryBackground

        let tabBar = UITabBar.appearance()
        tabBar.barTintColor = .named(.backgroundLightest)
        tabBar.tintColor = primary.ensureContrast(against: .named(.backgroundLightest))
        tabBar.unselectedItemTintColor = .named(.ash)

        let navigationBar = UINavigationBar.appearance()
        navigationBar.backIndicatorImage = .icon(.back)
        navigationBar.backIndicatorTransitionMaskImage = .icon(.back)
    }

    public func apply(to navigationBar: UINavigationBar?) {
        navigationBar?.barTintColor = navBackground
        navigationBar?.tintColor = navIconFill.ensureContrast(against: navBackground)
        navigationBar?.barStyle = navBackground.luminance < 0.5 ? .black : .default
    }
}
