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
        let hasEnoughContrast = brand.primary.contrast(against: UIColor.backgroundLightest) >= 3
        tintColor = hasEnoughContrast ? brand.primary : brand.navTextColor

        barStyle = .default
        barTintColor = .backgroundLightest
        unselectedItemTintColor = .textDark

        // There are weird RN view sizing issues with opaque tabBars, so emulate with backgroundColor.
        isTranslucent = true
        backgroundColor = .backgroundLightest

        for item in items ?? [] {
            item.badgeColor = .crimson
            item.setBadgeTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        }
    }

    public static func updateFontAppearance() {
        let attributes = [NSAttributedString.Key.font: UIFont.scaledNamedFont(.regular12)]
        let appearance = UITabBarItem.appearance()
        appearance.setTitleTextAttributes(attributes, for: .normal)
        appearance.setBadgeTextAttributes(attributes, for: .normal)
    }
}
