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

struct CourseListWidgetSeeAllCoursesView: View {
    let count: Int
    let onTap: () -> Void

    var body: some View {
        VStack(spacing: .huiSpaces.space16) {
            Image.huiIcons.book2Filled
                .foregroundStyle(Color.huiColors.surface.institution)
                .accessibilityHidden(true)

            Text(
                String.localizedStringWithFormat(
                    String(localized: "You’re enrolled in %d courses.", bundle: .horizon), count
                )
            )
            .foregroundStyle(Color.huiColors.text.title)
            .huiTypography(.p1)

            HorizonUI.PrimaryButton(
                String(localized: "See all"),
                type: .grayOutline,
                isSmall: true,
                fillsWidth: true,
                trailing: Image.huiIcons.arrowForward
            ) {
                onTap()
            }
            .accessibilityLabel(String(localized: "See all courses", bundle: .horizon))
            .accessibilityHint(String(localized: "Double tap to navigate to all courses", bundle: .horizon))
            .accessibilityAddTraits(.isButton)
        }
        .padding(.huiSpaces.space24)
        .frame(height: 442)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
    }
}

#Preview {
    CourseListWidgetSeeAllCoursesView(count: 12) {}
        .padding()
}
