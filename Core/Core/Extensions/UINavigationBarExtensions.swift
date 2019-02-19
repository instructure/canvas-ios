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

extension UINavigationBar {
    public func useContextColor(_ color: UIColor?) {
        let foreground = UIColor.named(.textLightest)
        let background = color?.ensureContrast(against: foreground)
        tintColor = foreground
        barTintColor = background
        barStyle = .black
        isTranslucent = false
    }

    public func useGlobalNavStyle(brand: Brand = Brand.shared) {
        let background = brand.navBackground
        let foreground = brand.navTextColor.ensureContrast(against: background)
        tintColor = foreground
        barTintColor = background
        barStyle = background.luminance < 0.5 ? .black : .default
        isTranslucent = false
    }

    public func useModalStyle(brand: Brand = Brand.shared) {
        tintColor = brand.linkColor.ensureContrast(against: .named(.backgroundLightest))
        barTintColor = .named(.backgroundLightest)
        barStyle = .default
        isTranslucent = true
    }
}
