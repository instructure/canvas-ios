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

extension InstUI.Styles {

    public enum Elevation {

        public enum Shape {
            case cardSmall
            case cardLarge
            case pill

            var cornerRadius: CGFloat {
                switch self {
                case .cardSmall: 6
                case .cardLarge: 24
                case .pill: 100
                }
            }
        }
    }
}

extension View {

    public func elevation(
        _ shape: InstUI.Styles.Elevation.Shape,
        background: Color
    ) -> some View {
        self
            .background(background)
            .cornerRadius(shape.cornerRadius)
            .shadow(color: .black.opacity(0.08), radius: 2, y: 2)
            .shadow(color: .black.opacity(0.16), radius: 2, y: 1)
    }
}
