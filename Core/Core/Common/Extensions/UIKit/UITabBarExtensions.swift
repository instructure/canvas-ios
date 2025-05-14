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

extension UITabBar {
    /// Styles the `UITabBar` to use some elements of the organizations branding colors
    public func useGlobalNavStyle(brand: Brand = Brand.shared) {
        let itemAppearance = UITabBarItemAppearance.make(highlightColor: brand.tabBarHighlightColor)
        let tabBarAppearance = UITabBarAppearance.make(itemAppearance: itemAppearance)
        standardAppearance = tabBarAppearance
        scrollEdgeAppearance = tabBarAppearance
    }
}

private extension UITabBarItemAppearance {

    static func make(highlightColor: UIColor) -> UITabBarItemAppearance {
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = .textDark
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.textDark,
            .font: UIFont.scaledNamedFont(.semibold12)
        ]
        itemAppearance.normal.badgeBackgroundColor = .backgroundDanger
        itemAppearance.normal.badgeTextAttributes = [.foregroundColor: UIColor.textLightest]

        itemAppearance.selected.iconColor = highlightColor
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: highlightColor
        ]

        return itemAppearance
    }
}

private extension UITabBarAppearance {

    static func make(itemAppearance: UITabBarItemAppearance) -> UITabBarAppearance {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = .backgroundLightest
        tabBarAppearance.stackedLayoutAppearance = itemAppearance
        tabBarAppearance.inlineLayoutAppearance = itemAppearance
        tabBarAppearance.compactInlineLayoutAppearance = itemAppearance
        return tabBarAppearance
    }
}
