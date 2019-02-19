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

extension UITabBar {
    /// This makes the tabBar (almost) match the style of web's global nav.
    /// Web hides the border for the active tab, but is on the side where nothing touches it.
    /// We preserve the border since it's at the bottom of the scrollable area.
    public func useGlobalNavStyle(brand: Brand = Brand.shared) {
        let size = CGSize(width: 1, height: intrinsicContentSize.height - 1) // minus border
        let image = UIGraphicsImageRenderer(size: size).image { context in
            context.cgContext.setFillColor(UIColor.named(.backgroundLightest).cgColor)
            context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        selectionIndicatorImage = image.resizableImage(withCapInsets: .zero)
        tintColor = brand.navIconFillActive.ensureContrast(against: .named(.backgroundLightest))

        barStyle = brand.navBackground.luminance < 0.5 ? .black : .default
        barTintColor = brand.navBackground
        unselectedItemTintColor = brand.navIconFill.ensureContrast(against: brand.navBackground)

        // There are weird RN view sizing issues with opaque tabBars, so emulate with backgroundColor.
        isTranslucent = true
        backgroundColor = brand.navBackground

        for item in items ?? [] {
            item.badgeColor = brand.navBadgeBackground
            item.setBadgeTextAttributes([.foregroundColor: brand.navBadgeText], for: .normal)
            item.setTitleTextAttributes([.foregroundColor: brand.navTextColor], for: .normal)
            item.setTitleTextAttributes([.foregroundColor: brand.navTextColorActive], for: .selected)
        }
    }
}
