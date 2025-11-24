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
    case unclear = "Confusing"
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
        case .unclear: .huiColors.primitives.red57
        case .other: .huiColors.text.body
        }
    }

    var backgroundColor: Color {
        switch self {
        case .important: .huiColors.primitives.sea12
        case .unclear: .huiColors.primitives.red12
        case .other: Color.clear
        }
    }

    var borderStyle: String {
        switch self {
        case .important: "solid"
        default: "dashed"
        }
    }

    var label: String {
        switch self {
        case .unclear: String(localized: "Unclear", bundle: .horizon)
        case .important: String(localized: "Important", bundle: .horizon)
        case .other: String(localized: "All notes", bundle: .horizon)
        }
    }

    var icon: Image {
        switch self {
        case .important: Image.huiIcons.keepPin
        default: Image.huiIcons.help
        }
    }

    static var list: [DropdownMenuItem] {
        [
            .init(id: "1", name: String(localized: "All notes")),
            .init(id: "2", name: CourseNoteLabel.unclear.label, key: CourseNoteLabel.unclear.rawValue),
            .init(id: "3", name: CourseNoteLabel.important.label, key: CourseNoteLabel.important.rawValue)
        ]
    }

    var markNoteName: String {
        switch self {
        case .unclear: String(localized: "Mark unclear", bundle: .horizon)
        case .important: String(localized: "Mark important", bundle: .horizon)
        case .other: String(localized: "All notes", bundle: .horizon)
        }
    }

    var image: some View {
        switch self {
        case .unclear:
            Image.huiIcons.help
        case .important:
            Image.huiIcons.keepPin
        case .other:
            Image.huiIcons.editNote
        }
    }
}
