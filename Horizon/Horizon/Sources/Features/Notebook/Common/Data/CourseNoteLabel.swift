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
    // swiftlint:disable line_length
    private static let flagSVG = """
        M280-449.23V-130q0 12.75-8.63 21.37-8.63 8.63-21.38 8.63-12.76 0-21.37-8.63Q220-117.25 220-130v-653.84q0-15.37 10.4-25.76 10.39-10.4 25.76-10.4h508.3q9.85 0 17.74 4.56 7.9 4.55 12.54 11.84t5.76 16.22q1.11 8.92-2.99 18.2l-59.43 134.57 59.43 134.56q4.1 9.28 2.99 18.2-1.12 8.93-5.76 16.22t-12.54 11.84q-7.89 4.56-17.74 4.56zm0-60h449.31L686-605.38q-6.38-13.65-6.38-29.25t6.38-29.22L729.31-760H280zm0 0V-760z
    """

    private static let questionMarkSVG = """
        M598.23-639.31q0-49.54-33.11-79.58-33.12-30.03-87.43-30.03-34.38 0-60.96 14.03-26.58 14.04-45.89 42.27-11.38 16.08-30.42 19-19.03 2.93-33.27-9.3-10.53-9.16-12.03-22.96-1.5-13.81 6.42-26.2 30.46-46.07 75.35-70.07 44.88-24 100.8-24 89.31 0 145.39 51.15 56.07 51.15 56.07 133.23 0 43.46-18.61 79.65-18.62 36.2-63.46 77.89-42 38.08-57.31 61.81T522-369.08q-2.46 17.08-14.15 28.46-11.7 11.39-28.16 11.39t-28.15-11.27-11.69-27.73q0-40.15 18.34-73.42 18.35-33.27 61.43-71.58 46-40.38 62.3-67.39 16.31-27 16.31-58.69M477.69-100q-24.54 0-42.27-17.73T417.69-160t17.73-42.27T477.69-220t42.27 17.73T537.69-160t-17.73 42.27T477.69-100
    """

    static func color(_ label: CourseNoteLabel) -> Color? {
        label.color
    }
    // swiftlint:enable line_length

    static let imageMap = [
        CourseNoteLabel.confusing: (Image.huiIcons.help, questionMarkSVG),
        CourseNoteLabel.important: (Image.huiIcons.flag2, flagSVG)
    ]

    // MARK: Properties
    var color: Color {
        switch self {
        case .important: .huiColors.icon.action
        default: .huiColors.icon.error
        }
    }

    var label: String {
        self == .confusing ?
            String(localized: "Confusing", bundle: .horizon) :
            String(localized: "Important", bundle: .horizon)
    }

    func image(selected: Bool = true) -> some View {
        let color = selected ? self.color : HorizonUI.colors.lineAndBorders.containerStroke
        let image = CourseNoteLabel.imageMap[self]?.0 ?? Image.huiIcons.flag2
        return image.foregroundStyle(color)
    }

    var iconSVG: String {
        CourseNoteLabel.imageMap[self]?.1.trimmed() ?? CourseNoteLabel.flagSVG
    }
}
