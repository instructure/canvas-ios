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
    public enum Style: Equatable { case modal, global, color(UIColor?) }

    func useStyle(_ style: Style) {
        switch style {
        case .modal:
            useModalStyle()
        case .global:
            useGlobalNavStyle()
        case .color(let color):
            useContextColor(color)
        }
    }

    public func useContextColor(_ color: UIColor?) {
        guard let color = color else { return }
        let foreground = UIColor.white // always white, even in dark mode
        let background = color.ensureContrast(against: foreground)
        titleTextAttributes = [.foregroundColor: foreground]
        tintColor = foreground
        barTintColor = background
        barStyle = .black
        isTranslucent = false
        updateFontAppearance()
    }

    public func useGlobalNavStyle(brand: Brand = Brand.shared) {
        let background = brand.navBackground
        let foreground = brand.navTextColor.ensureContrast(against: background)
        titleTextAttributes = [.foregroundColor: foreground]
        tintColor = foreground
        barTintColor = background
        barStyle = background.luminance < 0.5 ? .black : .default
        isTranslucent = false
        updateFontAppearance()
    }

    public func useModalStyle(brand: Brand = Brand.shared) {
        let foreground = brand.linkColor.ensureContrast(against: .backgroundLightest)
        titleTextAttributes = [.foregroundColor: UIColor.textDarkest]
        tintColor = foreground
        barTintColor = .backgroundLightest
        barStyle = .default
        isTranslucent = false
        updateFontAppearance()
    }

    public func updateFontAppearance(useK5Fonts: Bool = AppEnvironment.shared.k5.isK5Enabled) {
        if useK5Fonts {
            titleTextAttributes?[NSAttributedString.Key.font] = UIFont.scaledNamedFont(.bold17)
        }
    }
}
