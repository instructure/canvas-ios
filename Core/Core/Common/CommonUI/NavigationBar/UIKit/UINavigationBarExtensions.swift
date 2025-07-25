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

    public typealias Style = NavigationBarStyle

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
        guard let color else { return }
        let foreground = UIColor.textLightest
        let background = color
        titleTextAttributes = [.foregroundColor: foreground]
        tintColor = foreground
        barTintColor = background
        barStyle = .black

        applyAppearanceChanges(backgroundColor: background, foregroundColor: foreground)
    }

    public func useGlobalNavStyle(brand: Brand = Brand.shared) {
        // TODO: Remove the isHorizon condition once horizon-specific logic is no longer needed.
        let isHorizon = AppEnvironment.shared.app == .horizon
        let background: UIColor = isHorizon ? .backgroundLightest : brand.navBackground
        let foreground: UIColor = isHorizon ? .backgroundDarkest : brand.navTextColor
        titleTextAttributes = [.foregroundColor: foreground]
        tintColor = foreground
        barTintColor = background
        barStyle = background.luminance < 0.5 ? .black : .default

        applyAppearanceChanges(backgroundColor: background, foregroundColor: foreground)
    }

    /**
     - parameters:
        - forcedTheme: Pass `.light` or `.dark` to lock the style to the specific theme. Use `nil` to keep it dynamic.
     */
    public func useModalStyle(
        brand: Brand = Brand.shared,
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

        applyAppearanceChanges(backgroundColor: backgroundColor, foregroundColor: foregroundColor)
    }

    private func applyAppearanceChanges(backgroundColor: UIColor?, foregroundColor: UIColor?) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()

        if let backgroundColor {
            appearance.backgroundColor = backgroundColor
        }

        if let foregroundColor {
            appearance.titleTextAttributes = [.foregroundColor: foregroundColor]
        }

        appearance.titleTextAttributes[.font] = UIFont.scaledNamedFont(.semibold16)
        appearance.buttonAppearance.normal.titleTextAttributes[.font] = UIFont.scaledNamedFont(.regular16)

        standardAppearance = appearance
        scrollEdgeAppearance = standardAppearance
    }

    // TODO: Remove the isHorizon condition once horizon-specific logic is no longer needed.
    private func clearNavigation() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .backgroundLightest
        appearance.shadowColor = .backgroundLightest
        appearance.titleTextAttributes = [.foregroundColor: UIColor.textDarkest]

        tintColor = UIColor.textDarkest
        standardAppearance = appearance
        scrollEdgeAppearance = appearance
        compactAppearance = appearance
        isTranslucent = true
        self.backgroundColor = .backgroundLightest
    }
}
