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

public extension HorizonUI.Pill.Style {
    struct Outline: Sendable {
        let backgroundColor: Color = .clear
        let borderColor: Color
        let textColor: Color
        
        public static let `default` = Outline(
            borderColor: .huiColors.surface.inversePrimary,
            textColor: .huiColors.text.body
        )
        
        public static let danger = Outline(
            borderColor: .huiColors.surface.error,
            textColor: .huiColors.text.error
        )
    }
    
    struct Solid: Sendable {
        let backgroundColor: Color
        let borderColor: Color = .clear
        let textColor: Color
        
        public static let `default` = Solid(
            backgroundColor: .huiColors.surface.inversePrimary,
            textColor: .huiColors.text.surfaceColored
        )
        
        public static let danger = Solid(
            backgroundColor: .huiColors.surface.error,
            textColor: .huiColors.text.surfaceColored
        )
    }
    
    struct Inline: Sendable {
        let backgroundColor: Color = .clear
        let borderColor: Color = .clear
        let textColor: Color
        
        public static let `default` = Inline(
            textColor: .huiColors.text.body
        )
        
        public static let danger = Inline(
            textColor: .huiColors.text.error
        )
    }
}