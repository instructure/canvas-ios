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
import HorizonUI

enum ProgramCardStatus {
    case active
    case locked
    case completed
    case notEnrolled
    case inProgress

    init(completionPercent: Double = 0, status: String) {
        switch status {
        case ProgramCourse.Status.locked.rawValue:
            self = .locked
        case ProgramCourse.Status.notEnrolled.rawValue:
            self = .notEnrolled
        case ProgramCourse.Status.enrolled.rawValue where completionPercent == 1:
            self = .completed
        case ProgramCourse.Status.enrolled.rawValue where completionPercent == 0:
            self = .active
        default:
            self = .inProgress
        }
    }

     var forgroundColor: Color {
        switch self {
        case .inProgress, .active: Color.huiColors.surface.institution
        default: Color.huiColors.text.title
        }
    }

    var borderColor: Color {
        switch self {
        case .locked: Color.huiColors.lineAndBorders.lineStroke
        case .completed: Color.huiColors.primitives.honey30
        default: Color.huiColors.lineAndBorders.containerStroke
        }
    }

    var isEnrolled: Bool {
        switch self {
        case .inProgress, .active, .completed:
            return true
        default:
            return false
        }
    }
}

