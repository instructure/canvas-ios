//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        HorizonUI.Chip(
            title: title,
            style: .custom(
                .init(
                    state: .default,
                    foregroundColor: isSelected
                        ? Color.huiColors.text.surfaceColored
                        : Color.huiColors.text.title,
                    backgroundNormal: isSelected
                        ? Color.huiColors.surface.inversePrimary
                        : Color.huiColors.surface.cardPrimary,
                    backgroundPressed: isSelected
                        ? Color.huiColors.surface.inverseSecondary
                        : Color.huiColors.surface.hover,
                    borderColor: Color.huiColors.surface.inversePrimary,
                    focusedBorderColor: Color.huiColors.surface.inversePrimary,
                    iconColor: isSelected
                        ? Color.huiColors.icon.surfaceColored
                        : Color.huiColors.surface.inversePrimary
                )
            ),
            size: .large,
            leadingIcon: isSelected ? Image.huiIcons.check : nil
        ) {
            onTap()
        }
        .accessibilityAddTraits(.isButton)
        .accessibilityValue(isSelected ? String(localized: "Selected") : String(localized: "Unselected"))
        .accessibilityHint(String(localized: "Double tap to toggle selection"))
    }
}
