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

struct ExpandTitleView: View {
    let title: String
    let isExpanded: Bool
    var body: some View {
        HStack(alignment: .top, spacing: .huiSpaces.space8) {
            Text(title)
                .huiTypography(.h3)
                .frame(alignment: .leading)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundStyle(Color.huiColors.text.title)

            Image.huiIcons.keyboardArrowDown
                .padding(.top, .huiSpaces.space4)
                .tint(Color.huiColors.icon.default)
                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                .animation(.easeInOut, value: isExpanded)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)
            Spacer()
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(isExpanded ? String(localized: "Double-tap to collapse") : String(localized: "Double-tap to expand"))
    }
}
