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
import HorizonUI

enum CourseNoteLabel: String, CaseIterable {
    case confusing = "Confusing"
    case important = "Important"
    case other = "Other"

    var color: Color? {
        switch self {
        case .confusing: .huiColors.icon.error
        case .important: .huiColors.icon.action
        default: nil
        }
    }

    var label: String {
        self == .confusing ?
            String(localized: "Confusing", bundle: .horizon) :
            String(localized: "Important", bundle: .horizon)
    }

    var image: some View {
        self == .confusing ?
        Image.huiIcons.help.foregroundStyle(self.color ?? .huiColors.icon.default) :
        Image.huiIcons.flag2.foregroundStyle(self.color ?? .huiColors.icon.default)
    }

    static func color(_ label: CourseNoteLabel) -> Color? {
        label.color
    }
}
