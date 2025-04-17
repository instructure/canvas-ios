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

public extension HorizonUI.ProgressBar {
    enum Size: Equatable {
        case small
        case medium
        
        var height: CGFloat {
            switch self {
            case .small:
                return 8
            case .medium:
                return 28
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .small:
                return .huiColors.primitives.white10.opacity(0.3)
            case .medium:
                return .clear
            }
        }
    }
}
