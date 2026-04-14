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

import Core
import HorizonUI
import SwiftUI

struct OfflineCourseRowView: View {
    let course: OfflineCourseItem
    let onToggle: () -> Void
    let onExpand: () -> Void

    var body: some View {
        HStack(spacing: .huiSpaces.space24) {
            OfflineCheckboxCell(
                state: course.selectionState,
                label: "\(course.name), \(course.size.defaultToEmpty)",
                action: onToggle
            )
            Button {
                withAnimation(.easeInOut(duration: 0.25)) { onExpand() }
            } label: {
                HStack {
                    courseInfoView
                    Spacer()
                    Image.huiIcons.keyboardArrowDown
                        .foregroundStyle(Color.huiColors.icon.default)
                        .rotationEffect(.degrees(course.isExpanded ? 180 : 0))
                        .animation(.easeInOut(duration: 0.25), value: course.isExpanded)
                        .frame(width: 24, height: 24)
                        .hidden(!course.hasSubItems)
                        .accessibilityHidden(true)
                }
                .padding(.vertical, .huiSpaces.space16)
                .frame(maxWidth: .infinity)
                .contentShape(.rect)
                .disabled(!course.hasSubItems)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(course.name)
            .accessibilityValue(
                course.isExpanded
                    ? String(localized: "Expanded", bundle: .horizon)
                    : String(localized: "Collapsed", bundle: .horizon)
            )
            .accessibilityHint(
                course.isExpanded
                    ? String(localized: "Double-tap to collapse", bundle: .horizon)
                    : String(localized: "Double-tap to expand", bundle: .horizon)
            )
            .accessibilityHidden(!course.hasSubItems)

        }
        .padding(.horizontal, .huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.huiColors.surface.divider)
                .frame(height: 1)
        }
    }

    @ViewBuilder
    private var courseInfoView: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space2) {
            Text(course.name)
                .huiTypography(.p1)
                .foregroundStyle(Color.huiColors.text.body)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            if let size = course.size {
                Text("~\(size)")
                    .huiTypography(.p2)
                    .foregroundStyle(Color.huiColors.text.timestamp)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
