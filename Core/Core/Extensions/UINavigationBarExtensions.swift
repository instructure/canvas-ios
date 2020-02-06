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

extension UINavigationBar {
    public func useContextColor(_ color: UIColor?) {
        let foreground = UIColor.named(.white) // always white, even in dark mode
        let background = color?.ensureContrast(against: foreground)
        titleTextAttributes = [.foregroundColor: foreground]
        tintColor = foreground
        barTintColor = background
        barStyle = .default
        isTranslucent = false
    }

    public func useGlobalNavStyle(brand: Brand = Brand.shared) {
        let background = brand.navBackground
        let foreground = brand.navTextColor.ensureContrast(against: background)
        titleTextAttributes = [.foregroundColor: foreground]
        tintColor = foreground
        barTintColor = background
        barStyle = background.luminance < 0.5 ? .black : .default
        isTranslucent = false
    }

    public func useModalStyle(brand: Brand = Brand.shared) {
        let foreground = brand.linkColor.ensureContrast(against: .named(.backgroundLightest))
        titleTextAttributes = [.foregroundColor: UIColor.named(.textDarkest)]
        tintColor = foreground
        barTintColor = .named(.backgroundLightest)
        barStyle = .default
        isTranslucent = true

        shadowImage = nil
        setBackgroundImage(nil, for: .default)
    }
}
