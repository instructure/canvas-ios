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

enum ModuleNavBarUtilityButtons: Hashable {
    case tts
    case chatBot(courseId: String? = nil, pageUrl: String? = nil, fileId: String? = nil) /// provide either no values, or course ID and either pageUr, or fileId
    case notebook
    case assignmentMoreOptions

    var image: Image {
        switch self {
        case .tts:
            Image.huiIcons.volumeUp
        case .chatBot:
            Image(.chatBot)
        case .notebook:
            Image.huiIcons.menuBookNotebook
        case .assignmentMoreOptions:
            Image.huiIcons.moreVert
        }
    }
}
