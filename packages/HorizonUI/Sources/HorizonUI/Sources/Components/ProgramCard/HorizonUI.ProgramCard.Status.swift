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

public extension HorizonUI.ProgramCard {
    enum Status {
        case active
        case locked
        case completed
        case inProgress(completionPercent: Double)

        public init(completionPercent: Double = 0, status: String) {
            switch status {
            case "BLOCKED":
                self = .locked
            case "NOT_ENROLLED":
                self = .active
            case "ENROLLED" where completionPercent == 100:
                self = .completed
            case "ENROLLED" where completionPercent == 0:
                self = .active
            default:
                self = .inProgress(completionPercent: completionPercent)
            }
        }

        public var forgroundColor: Color {
            switch self {
            case .inProgress, .active: Color.huiColors.surface.institution
            default: Color.huiColors.text.title
            }
        }

        public var borderColor: Color {
            switch self {
            case .locked: Color.huiColors.lineAndBorders.lineStroke
            case .completed: Color.huiColors.primitives.honey30
            default: Color.huiColors.lineAndBorders.containerStroke
            }
        }

        public var isCompleted: Bool {
            switch self {
            case .completed:
                return true
            default:
                return false
            }
        }

        public var isActive: Bool {
            switch self {
            case .active:
                return true
            default:
                return false
            }
        }

        var isLocked: Bool {
            switch self {
            case .locked:
                return true
            default:
                return false
            }
        }

       public var isEnrolled: Bool {
            switch self {
            case .inProgress, .active, .completed:
                return true
            default:
                return false
            }
        }
    }
}
