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
    enum Elevations: CaseIterable {
        case level1
        case level2
        case level3
        case level4
        case level5

        var attributes: ElevationAttributes {
            switch self {
            case .level1:
                return ElevationAttributes(
                    x: 0,
                    y: 2,
                    blur: 3,
                    spread: 0,
                    // TODO: Use predefined color
                    color: Color(hexString: "#2735401A")
                )
            case .level2:
                return ElevationAttributes(
                    x: 0,
                    y: 2,
                    blur: 5,
                    spread: 0,
                    // TODO: Use predefined color
                    color: Color(hexString: "#2735401A")
                )
            case .level3:
                return ElevationAttributes(
                    x: 0,
                    y: 2,
                    blur: 9,
                    spread: 1,
                    // TODO: Use predefined color
                    color: Color(hexString: "#2735401A")
                )
            case .level4:
                return ElevationAttributes(
                    x: 1,
                    y: 2,
                    blur: 8,
                    spread: 0,
                    color: Color(hexString: "#2735401A")
                )
            case .level5:
                return ElevationAttributes(
                    x: 1,
                    y: 2,
                    blur: 12,
                    spread: 0,
                    // TODO: Use predefined color
                    color: Color(hexString: "#2735401A")
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

public extension View {
    func huiElevation(level: HorizonUI.Elevations) -> some View {
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