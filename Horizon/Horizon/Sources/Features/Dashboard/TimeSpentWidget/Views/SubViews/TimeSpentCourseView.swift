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

struct TimeSpentCourseView: View {
    let name: String
    let isSelected: Bool

    var body: some View {
        HStack(spacing: .huiSpaces.space4) {
            if isSelected {
                Image.huiIcons.check
                    .frame(width: 24, height: 24)
            }
            Text(name)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
                .frame(minHeight: 42)
                .huiTypography(.buttonTextMedium)
        }
        .padding(.horizontal, .huiSpaces.space16)
        .foregroundStyle(
            isSelected
            ? Color.huiColors.surface.pageSecondary
            : Color.huiColors.text.body
        )
        .background(
            isSelected
            ? Color.huiColors.surface.inversePrimary
            : Color.clear
        )
    }
}
