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

extension HorizonUI {
    public enum Elevations: CaseIterable {
        case level0
        case level1
        case level2
        case level3
        case level4
        case level5

        var attributes: ElevationAttributes {

            let shadowColor: Color = .huiColors.primitives.grey125.opacity(0.18)

            switch self {
            case .level0:
                // When we want toggle between having no elevation and one of the other elevation levels
                return ElevationAttributes(
                    x: 0,
                    y: 0,
                    blur: 0,
                    spread: 0,
                    color: Color.clear
                )
            case .level1:
                return ElevationAttributes(
                    x: 0,
                    y: 2,
                    blur: 3,
                    spread: 0,
                    color: shadowColor
                )
            case .level2:
                return ElevationAttributes(
                    x: 0,
                    y: 2,
                    blur: 5,
                    spread: 0,
                    color: shadowColor
                )
            case .level3:
                return ElevationAttributes(
                    x: 0,
                    y: 2,
                    blur: 9,
                    spread: 1,
                    color: shadowColor
                )
            case .level4:
                return ElevationAttributes(
                    x: 1,
                    y: 2,
                    blur: 8,
                    spread: 0,
                    color: shadowColor
                )
            case .level5:
                return ElevationAttributes(
                    x: 1,
                    y: 2,
                    blur: 12,
                    spread: 0,
                    color: shadowColor
                )
            }
        }

        struct ElevationAttributes {
            let x: Double
            let y: Double
            let blur: Double
            let spread: Double
            let color: Color
        }
    }
}

extension View {
    public func huiElevation(level: HorizonUI.Elevations) -> some View {
        let spreadModifier = level.attributes.spread > 0 ? level.attributes.spread : 0

        return padding(spreadModifier)
            .background(
                ZStack {
                    if level.attributes.spread > 0 {
                        self
                            .shadow(
                                color: level.attributes.color,
                                radius: level.attributes.blur / 2,
                                x: level.attributes.x,
                                y: level.attributes.y
                            )
                            .padding(-spreadModifier)
                    } else {
                        self
                            .shadow(
                                color: level.attributes.color,
                                radius: level.attributes.blur / 2,
                                x: level.attributes.x,
                                y: level.attributes.y
                            )
                    }
                }
            )
    }
}
