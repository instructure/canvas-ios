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

public extension HorizonUI.StatusChip {
    enum Style {
        case white
        case gray
        case green // Success
        case blue
        case sky
        case hone
        case orange // Warning
        case red // Error
        case gum
        case plum
        case vilot
        case institution

        func forgroundColor(isFilled: Bool) -> Color {
            switch self {
            case .white: isFilled ? Color.huiColors.text.title : Color.huiColors.text.surfaceColored
            case .gray: Color.huiColors.text.title
            case .green: Color.huiColors.primitives.green82
            case .blue: Color.huiColors.primitives.blue82
            case .sky: Color.huiColors.primitives.sky82
            case .hone: Color.huiColors.primitives.honey90
            case .orange: Color.huiColors.primitives.orange82
            case .red: Color.huiColors.primitives.red82
            case .gum: Color.huiColors.primitives.gum90
            case .plum: Color.huiColors.primitives.plum90
            case .vilot: Color.huiColors.primitives.violet90
            case .institution: isFilled ? Color.huiColors.text.surfaceColored : Color.huiColors.surface.institution
            }
        }

        var backgroundColor: Color {
            switch self {
            case .white: Color.huiColors.surface.pageSecondary
            case .gray: Color.huiColors.primitives.grey11
            case .green: Color.huiColors.primitives.green12
            case .blue: Color.huiColors.primitives.blue12
            case .sky: Color.huiColors.primitives.sky12
            case .hone:  Color.huiColors.primitives.honey12
            case .orange:  Color.huiColors.primitives.orange12
            case .red: Color.huiColors.primitives.red12
            case .gum: Color.huiColors.primitives.gum12
            case .plum: Color.huiColors.primitives.plum12
            case .vilot: Color.huiColors.primitives.violet12
            case .institution: Color.huiColors.surface.institution
            }
        }

        func iconColor(isFilled: Bool) -> Color {
            switch self {
            case .white: isFilled ? Color.huiColors.icon.default : Color.huiColors.icon.surfaceColored
            case .gray: Color.huiColors.icon.default
            case .green: Color.huiColors.primitives.green82
            case .blue: Color.huiColors.primitives.blue82
            case .sky: Color.huiColors.primitives.sky90
            case .hone:  Color.huiColors.primitives.honey90
            case .orange: Color.huiColors.primitives.orange82
            case .red: Color.huiColors.primitives.red82
            case .gum: Color.huiColors.primitives.gum90
            case .plum: Color.huiColors.primitives.plum90
            case .vilot: Color.huiColors.primitives.violet90
            case .institution: isFilled ? Color.huiColors.icon.surfaceColored : Color.huiColors.surface.institution
            }
        }
    }
}
