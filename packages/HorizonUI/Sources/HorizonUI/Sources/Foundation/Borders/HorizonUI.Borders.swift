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
    enum Borders: CaseIterable {
        case level1

        var attributes: BorderAttributes {
            switch self {
            case .level1:
                return BorderAttributes(
                    width: 1,
                    // TODO: Use predefined color
                    color: Color(hexString: "#D7DADE")
                )
            }
        }
    }

    struct BorderAttributes {
        let width: Double
        let color: Color
    }
}

public extension View {
    func huiBorder(
        level: HorizonUI.Borders,
        radius: Double = 0
    ) -> some View {
        RoundedRectangle(cornerRadius: radius)
            .strokeBorder(level.attributes.color, lineWidth: level.attributes.width)
    }
}
