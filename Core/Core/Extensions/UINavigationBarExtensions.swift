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
    public enum Style: Equatable { case modal, modalLight, global, color(UIColor?) }

    func useStyle(_ style: Style) {
        switch style {
        case .modal:
            useModalStyle()
        case .modalLight:
            useModalStyle(isLightFont: true)
        case .global:
            useGlobalNavStyle()
        case .color(let color):
            useContextColor(color)
        }
    }

    public func useContextColor(_ color: UIColor?, isTranslucent: Bool = false) {
        guard let color = color else { return }
        let foreground = UIColor.textLightest // always white, even in dark mode
        let background = color.resolvedColor(with: .light).darkenToEnsureContrast(against: foreground)
        titleTextAttributes = [.foregroundColor: foreground]
        tintColor = foreground
        barTintColor = background
        barStyle = .black
        self.isTranslucent = isTranslucent

        applyAppearanceChanges(backgroundColor: background, foreGroundColor: foreground)
    }

    public func useGlobalNavStyle(brand: Brand = Brand.shared) {
        let background = brand.navBackground
        let foreground = brand.navTextColor
        titleTextAttributes = [.foregroundColor: foreground]
        tintColor = foreground
        barTintColor = background
        barStyle = background.luminance < 0.5 ? .black : .default
        isTranslucent = false

        applyAppearanceChanges(backgroundColor: background, foreGroundColor: foreground)
    }

    public func useModalStyle(brand: Brand = Brand.shared, isLightFont: Bool = false) {
        let foreground = brand.linkColor
        titleTextAttributes = [.foregroundColor: UIColor.textDarkest]
        tintColor = foreground
        barTintColor = .backgroundLightest
        barStyle = .default
        isTranslucent = false

        applyAppearanceChanges(backgroundColor: .backgroundLightest, foreGroundColor: UIColor.textDarkest, isLightFont: isLightFont)
    }

    private func applyAppearanceChanges(backgroundColor: UIColor?, foreGroundColor: UIColor?, isLightFont: Bool = false) {
        let appearance = UINavigationBarAppearance()

        if isTranslucent {
            appearance.configureWithTransparentBackground()
        } else {
            appearance.configureWithDefaultBackground()

            if let backgroundColor = backgroundColor {
                appearance.backgroundColor = backgroundColor
            }
        }

        if let foreGroundColor = foreGroundColor {
            appearance.titleTextAttributes = [.foregroundColor: foreGroundColor]
        }

        appearance.titleTextAttributes[.font] = UIFont.scaledNamedFont(isLightFont ? .semibold16 : .bold17)
        appearance.buttonAppearance.normal.titleTextAttributes[.font] = UIFont.scaledNamedFont(isLightFont ? .semibold16 : .regular17)

        standardAppearance = appearance
        scrollEdgeAppearance = standardAppearance
    }
}
