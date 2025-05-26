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
    enum CornerRadius: CaseIterable {
        /// Helper variant when conditional corner radius is applied
        case level0
        case level1
        case level1_5
        case level2
        case level3
        case level3_5
        case level4
        case level5
        case level6

        public typealias CornerAttributes = SmoothRoundedRectangle.CornerAttributes

        public var attributes: CornerAttributes {
            switch self {
            case .level0:
                CornerAttributes(radius: 0, smoothness: 0)
            case .level1:
                CornerAttributes(radius: 8, smoothness: 0)
            case .level1_5:
                CornerAttributes(radius: 12, smoothness: 0)
            case .level2:
                CornerAttributes(radius: 16, smoothness: 60)
            case .level3:
                CornerAttributes(radius: 16, smoothness: 0)
            case .level3_5:
                CornerAttributes(radius: 24, smoothness: 0)
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
    @ViewBuilder
    func huiCornerRadius(
        level: HorizonUI.CornerRadius,
        corners: HorizonUI.Corners? = [.all]
    ) -> some View {
        if level != .level0, let corners {
            clipShape(
                HorizonUI.SmoothRoundedRectangle(
                    radius: level.attributes.radius,
                    corners: corners,
                    smoothness: level.attributes.smoothness
                )
            )
        } else {
            self
        }
    }
}
