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

struct SeeAllCoursesButton: View {
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: .huiSpaces.space10) {
                Text("See all courses")
                    .huiTypography(.buttonTextLarge)
                    .foregroundStyle(Color.huiColors.text.title)
                    .frame(alignment: .center)
                Image.huiIcons.arrowForward
                    .foregroundStyle(Color.huiColors.icon.default)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .huiSpaces.space10)
            .background(Color.huiColors.surface.pageSecondary)
            .huiCornerRadius(level: .level6)
            .huiElevation(level: .level4)
            .padding(.top, .huiSpaces.space16)
            .padding(.horizontal, .huiSpaces.space24)
        }
    }
}

#Preview {
    SeeAllCoursesButton {}
}
