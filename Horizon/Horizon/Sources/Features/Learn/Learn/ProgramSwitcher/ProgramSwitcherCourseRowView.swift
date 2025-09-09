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

struct ProgramSwitcherCourseRowView: View {
    let course: ProgramSwitcherModel.Course
    let isSelected: Bool

    var body: some View {
        HStack {
            Text(course.name)
                .frame(minHeight: 42)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(
                    isSelected
                    ? Color.huiColors.surface.pagePrimary
                    : Color.huiColors.text.body
                )
                .huiTypography(.buttonTextLarge)
                .multilineTextAlignment(.leading)

            Spacer()

            if !course.isEnrolled {
                Image.huiIcons.lock
                    .foregroundStyle(Color.huiColors.icon.default)
            }
        }
        .padding(.horizontal, .huiSpaces.space16)
        .background(
            isSelected
            ? Color.huiColors.surface.inverseSecondary
            : .clear
        )
        .opacity(course.isEnrolled ? 1 : 0.5)
    }
}
