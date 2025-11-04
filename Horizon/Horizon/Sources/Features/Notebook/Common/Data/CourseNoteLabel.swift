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

    // MARK: Static
    static func color(_ label: CourseNoteLabel) -> Color? {
        label.color
    }

    // MARK: Properties
    var color: Color {
        switch self {
        case .important: .huiColors.primitives.sea57
        default: .huiColors.primitives.red57
        }
    }

    var borderStyle: String {
        switch self {
        case .important: "solid"
        default: "dashed"
        }
    }

    var label: String {
        self == .confusing ?
            String(localized: "Confusing", bundle: .horizon) :
            String(localized: "Important", bundle: .horizon)
    }

    func image(selected: Bool = true) -> some View {
        let color = selected ? self.color : HorizonUI.colors.lineAndBorders.containerStroke
        let image = self == .confusing ? Image.huiIcons.help : Image.huiIcons.flag2
        return image.foregroundStyle(color)
    }
}
