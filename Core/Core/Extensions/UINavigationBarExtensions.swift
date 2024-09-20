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
        guard let color else { return }
        let foreground = UIColor.textLightest
        let background = color
        titleTextAttributes = [.foregroundColor: foreground]
        tintColor = foreground
        barTintColor = background
        barStyle = .black
        self.isTranslucent = isTranslucent

        applyAppearanceChanges(backgroundColor: background, foregroundColor: foreground)
    }

    public func useGlobalNavStyle(brand: Brand = Brand.shared) {
        let background = brand.navBackground
        let foreground = brand.navTextColor
        titleTextAttributes = [.foregroundColor: foreground]
        tintColor = foreground
        barTintColor = background
        barStyle = background.luminance < 0.5 ? .black : .default
        isTranslucent = false

        applyAppearanceChanges(backgroundColor: background, foregroundColor: foreground)
    }

    /**
     - parameters:
        - forcedTheme: Pass `.light` or `.dark` to lock the style to the specific theme. Use `nil` to keep it dynamic.
     */
    public func useModalStyle(
        brand: Brand = Brand.shared,
        isLightFont: Bool = false,
        forcedTheme: UITraitCollection? = nil
    ) {
        var backgroundColor = UIColor.backgroundLightest
        var foregroundColor = UIColor.textDarkest

        if let forcedTheme {
            backgroundColor = backgroundColor.resolvedColor(with: forcedTheme)
            foregroundColor = foregroundColor.resolvedColor(with: forcedTheme)
        }

        let foreground = brand.linkColor
        titleTextAttributes = [.foregroundColor: foregroundColor]
        tintColor = foreground
        barTintColor = backgroundColor
        barStyle = .default
        isTranslucent = false

        applyAppearanceChanges(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            isLightFont: isLightFont
        )
    }

    private func applyAppearanceChanges(backgroundColor: UIColor?, foregroundColor: UIColor?, isLightFont: Bool = false) {
        let appearance = UINavigationBarAppearance()

        if isTranslucent {
            appearance.configureWithTransparentBackground()
        } else {
            appearance.configureWithDefaultBackground()

            if let backgroundColor = backgroundColor {
                appearance.backgroundColor = backgroundColor
            }
        }

        if let foreGroundColor = foregroundColor {
            appearance.titleTextAttributes = [.foregroundColor: foreGroundColor]
        }

        appearance.titleTextAttributes[.font] = UIFont.scaledNamedFont(isLightFont ? .semibold16 : .bold17)
        appearance.buttonAppearance.normal.titleTextAttributes[.font] = UIFont.scaledNamedFont(isLightFont ? .semibold16 : .regular17)

        standardAppearance = appearance
        scrollEdgeAppearance = standardAppearance
    }
}
