//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

public extension HorizonUI {
    enum CornerRadius: Float, CaseIterable {
        case level1
        case level2
        case level3
        case level4
        case level5
        case level6

        public typealias CornerAttributes = SmoothRoundedRectangle.CornerAttributes

        public var attributes: CornerAttributes {
            switch self {
            case .level1:
                CornerAttributes(radius: 8, smoothness: 0)
            case .level2:
                CornerAttributes(radius: 16, smoothness: 60)
            case .level3:
                CornerAttributes(radius: 16, smoothness: 0)
            case .level4:
                CornerAttributes(radius: 32, smoothness: 60)
            case .level5:
                CornerAttributes(radius: 32, smoothness: 0)
            case .level6:
                CornerAttributes(radius: 100, smoothness: 0)
            }
        }
    }
}

public extension View {
    func huiCornerRadius(
        level: HorizonUI.CornerRadius,
        corners: HorizonUI.Corners = [.all]
    ) -> some View {
        clipShape(
            HorizonUI.SmoothRoundedRectangle(
                radius: level.attributes.radius,
                corners: corners,
                smoothness: level.attributes.smoothness
            )
        )
    }
}
