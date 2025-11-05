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

import HorizonUI
import SwiftUI

struct TimeSpentWidgetCourseButton: View {
    let courseName: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HorizonUI.Chip(
            title: courseName,
            style: .custom(
                .init(
                    state: .default,
                    foregroundColor: isSelected
                    ? Color.huiColors.text.title
                    : Color.huiColors.surface.pageSecondary,
                    backgroundNormal: isSelected
                    ? Color.huiColors.surface.cardPrimary
                    : Color.huiColors.surface.inversePrimary,
                    backgroundPressed: Color.huiColors.surface.hover,
                    borderColor: Color.huiColors.surface.inversePrimary,
                    focusedBorderColor: Color.huiColors.lineAndBorders.lineStroke,
                    iconColor: Color.huiColors.surface.inversePrimary
                )
            ),
            size: .large,
            trallingIcon: Image.huiIcons.keyboardArrowDown
        ) {
            onTap()
        }
    }
}

#Preview {
    TimeSpentWidgetCourseButton(
        courseName: "Introduction to SwiftUI",
        isSelected: true
    ) {}
}
