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

struct AnnouncementWidgetView: View {
    let announcement: NotificationModel
    let currentIndex: Int
    let totalCount: Int
    let isCounterVisible: Bool
    let focusedAnnouncementID: AccessibilityFocusState<String?>.Binding

    init(
        announcement: NotificationModel,
        currentIndex: Int,
        totalCount: Int,
        isCounterVisible: Bool,
        focusedAnnouncementID: AccessibilityFocusState<String?>.Binding,
    ) {
        self.announcement = announcement
        self.currentIndex = currentIndex
        self.totalCount = totalCount
        self.isCounterVisible = isCounterVisible
        self.focusedAnnouncementID = focusedAnnouncementID
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space4) {
            VStack(alignment: .leading, spacing: .huiSpaces.space4) {
                headerView
                if let courseName = announcement.courseName {
                    Text(courseName)
                        .lineLimit(1)
                        .huiTypography(.p2)
                        .foregroundStyle(Color.huiColors.text.dataPoint)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .skeletonLoadable()
                        .accessibilityHidden(true)
                }

                Text(announcement.dateFormatted)
                    .huiTypography(.p3)
                    .foregroundStyle(Color.huiColors.text.timestamp)
                    .padding(.bottom, .huiSpaces.space4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .skeletonLoadable()
                    .accessibilityHidden(true)

                Text(announcement.title)
                    .huiTypography(.p1)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(Color.huiColors.text.body)
                    .padding(.bottom, .huiSpaces.space10)
                    .padding(.bottom, .huiSpaces.space2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .skeletonLoadable()
                    .accessibilityHidden(true)
            }
            .padding(.huiSpaces.space24)
            .background(Color.huiColors.surface.pageSecondary)
            .huiCornerRadius(level: .level5)
            .huiElevation(level: .level4)
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text(combinedAccessibilityLabel))
            .accessibilityFocused(focusedAnnouncementID, equals: announcement.id)
        }
    }

    private var headerView: some View {
        HStack(spacing: .zero) {
            HorizonUI.StatusChip(
                title: announcement.type.title,
                style: announcement.type.style
            )
            .padding(.bottom, .huiSpaces.space10)
            .padding(.bottom, .huiSpaces.space2)
            .skeletonLoadable()
            .accessibilityHidden(true)
            Spacer()
            if isCounterVisible {
                countView
            }
        }
    }

    private var countView: some View {
        Text(
            String(
                format: String(localized: "%@ of %@"),
                (currentIndex + 1).description,
                totalCount.description
            )
        )
        .huiTypography(.p1)
        .foregroundStyle(Color.huiColors.text.dataPoint)
        .skeletonLoadable()
    }

    private var combinedAccessibilityLabel: String {
        var components: [String] = []
        components.append(announcement.type.title)
        if announcement.courseName != nil {
            components.append(announcement.accessibilityCourseName)
        }
        components.append(announcement.accessibilityDate)
        components.append(announcement.accessibilityTitle)

        if isCounterVisible {
            let counterText = String(
                format: String(localized: "Announcement %@ of %@"),
                (currentIndex + 1).description,
                totalCount.description
            )
            components.append(counterText)
        }

        return components.joined(separator: ", ")
    }
}

#Preview {
    @Previewable @AccessibilityFocusState var focusState: String?

    AnnouncementWidgetView(
        announcement: .init(
            id: "1",
            title: "The full announcement could be shown here, or we could truncate it. Lorem ipsum dolor sit amet, consectetur adipiscing elit,",
            date: Date(),
            isRead: true,
            courseName: "Course Name",
            type: .announcement
        ),
        currentIndex: 1,
        totalCount: 10,
        isCounterVisible: true,
        focusedAnnouncementID: $focusState
    )
}
