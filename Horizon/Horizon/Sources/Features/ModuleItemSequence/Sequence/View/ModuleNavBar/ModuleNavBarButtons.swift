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

import Core
import HorizonUI
import SwiftUI

enum ModuleNavBarButtons {
    case previous
    case next

    var image: Image {
        switch self {
        case .previous:
            Image.huiIcons.chevronLeft
        case .next:
            Image.huiIcons.chevronRight
        }
    }
}

enum ModuleNavBarUtilityButtons: Equatable, Hashable {
    typealias OnTap = (WeakViewController) -> Void

    case tts(OnTap? = nil)
    case chatBot(OnTap? = nil)
    case notebook(OnTap? = nil)
    case assignmentMoreOptions(OnTap? = nil, hasBadge: Bool = false)

    var image: Image? {
        switch self {
        case .tts:
            Image.huiIcons.volumeUp
        case .chatBot:
            nil // use the default for the buttonStyle
        case .notebook:
            Image.huiIcons.menuBookNotebook
        case .assignmentMoreOptions:
            Image.huiIcons.moreVert
        }
    }

    var buttonStyle: HorizonUI.ButtonStyles.ButtonType {
        switch self {
        case .chatBot:
            return .ai
        default:
            return .white
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .tts:
            hasher.combine("tts")
        case .chatBot:
            hasher.combine("chatBot")
        case .notebook:
            hasher.combine("notebook")
        case .assignmentMoreOptions:
            hasher.combine("assignmentMoreOptions")
        }
    }

    var onTap: OnTap? {
        switch self {
        case .tts(let onTap),
                .chatBot(let onTap),
                .notebook(let onTap),
                .assignmentMoreOptions(let onTap, _):
            return onTap
        }
    }

    var hasBadge: Bool {
        switch self {
        case .assignmentMoreOptions(_, hasBadge: let hasBadge):
            return hasBadge
        default:
            return false
        }
    }

    static func == (lhs: ModuleNavBarUtilityButtons, rhs: ModuleNavBarUtilityButtons) -> Bool {
        switch (lhs, rhs) {
        case (.tts, .tts),
             (.chatBot, .chatBot),
             (.notebook, .notebook),
             (.assignmentMoreOptions, .assignmentMoreOptions):
            return true
        default:
            return false
        }
    }
}
