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

struct OfflineSubItemRowView: View {
    let subItem: OfflineFileItem
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: .huiSpaces.space24) {
            OfflineCheckboxCell(
                state: subItem.isSelected ? .checked : .unchecked,
                label: "\(subItem.name), \(subItem.size)",
                action: onToggle
            )
            fileInfoView
                .accessibilityHidden(true)
        }
        .background(Color.huiColors.surface.pageSecondary)
        .padding(.horizontal, .huiSpaces.space48)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.huiColors.surface.divider)
                .frame(height: 1)
        }
    }

    private var fileInfoView: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space2) {
            Text(subItem.name)
                .huiTypography(.p1)
                .foregroundStyle(Color.huiColors.text.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            Text("~\(subItem.size)")
                .huiTypography(.p2)
                .foregroundStyle(Color.huiColors.text.timestamp)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, .huiSpaces.space16)
        .frame(maxWidth: .infinity)
    }
}
