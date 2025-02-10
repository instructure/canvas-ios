//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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

import SwiftUI

struct NavigationBarColorConfiguration {
    var title: Color
    var subtitle: Color
    var tint: Color

    // private, because currently we don't want to allow custom configurations
    private init(title: Color, subtitle: Color, tint: Color) {
        self.title = title
        self.subtitle = subtitle
        self.tint = tint
    }

    init(style: NavigationBarStyle, brand: Brand = .shared) {
        switch style {
        case .modal:
            self.init(
                title: .textDarkest,
                subtitle: .textDark,
                tint: brand.linkColor.asColor
            )
        case .global:
            let color = brand.navTextColor.asColor
            self.init(title: color, subtitle: color, tint: color)
        case .color:
            let color = Color.textLightest
            self.init(title: color, subtitle: color, tint: color)
        }
    }
}

