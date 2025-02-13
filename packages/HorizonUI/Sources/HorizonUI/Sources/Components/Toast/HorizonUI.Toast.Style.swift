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

public extension HorizonUI.Toast {
    enum Style {
        case info
        case success
        case warning
        case error

        var color: Color {
            switch self {
            case .info: HorizonUI.colors.surface.attention
            case .success: HorizonUI.colors.surface.success
            case .warning: HorizonUI.colors.surface.warning
            case .error: HorizonUI.colors.surface.error
            }
        }

        var image: Image {
            switch self {
            case .info: HorizonUI.icons.info
            case .success: HorizonUI.icons.check
            case .warning: HorizonUI.icons.warning
            case .error: HorizonUI.icons.error
            }
        }
    }

    enum Buttons {
        case single(confirmButton: ButtonAttribute)
        case double(cancelButton: ButtonAttribute, confirmButton: ButtonAttribute)
    }
}
