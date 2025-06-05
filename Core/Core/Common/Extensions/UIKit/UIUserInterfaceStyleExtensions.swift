//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

extension UIUserInterfaceStyle {

    public static var current: UIUserInterfaceStyle {
        var style = AppEnvironment.shared.userDefaults?.interfaceStyle ?? .unspecified

        if style == .unspecified {
            style = UIScreen.main.traitCollection.userInterfaceStyle
        }

        return style
    }
}

extension UIUserInterfaceStyle: OptionItemIdentifiable {
    public var optionItemId: String {
        switch self {
        case .unspecified: "system"
        case .light: "light"
        case .dark: "dark"
        @unknown default: "_unknown"
        }
    }

    public var settingsTitle: String {
        switch self {
        case .unspecified: String(localized: "System Settings", bundle: .core)
        case .light: String(localized: "Light Theme", bundle: .core)
        case .dark: String(localized: "Dark Theme", bundle: .core)
        @unknown default: ""
        }
    }
}
