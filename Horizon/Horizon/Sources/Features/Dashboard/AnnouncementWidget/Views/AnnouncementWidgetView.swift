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
    let onTap: (NotificationModel) -> Void
    let focusedAnnouncementID: AccessibilityFocusState<String?>.Binding

    init(
        announcement: NotificationModel,
        focusedAnnouncementID: AccessibilityFocusState<String?>.Binding,
        onTap: @escaping ((NotificationModel) -> Void)
    ) {
        self.announcement = announcement
        self.focusedAnnouncementID = focusedAnnouncementID
        self.onTap = onTap
    }

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space4) {
            HorizonUI.StatusChip(
                title: announcement.type.title,
                style: announcement.type.style
            )
            .padding(.bottom, .huiSpaces.space10)
            .padding(.bottom, .huiSpaces.space2)
            .skeletonLoadable()

            if let courseName = announcement.courseName {
                Text(courseName)
                    .lineLimit(1)
                    .huiTypography(.p2)
                    .foregroundStyle(Color.huiColors.text.dataPoint)
                    .accessibilityLabel(announcement.accessibilityCourseName)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .skeletonLoadable()
            }

            Text(announcement.dateFormatted)
                .huiTypography(.p3)
                .foregroundStyle(Color.huiColors.text.timestamp)
                .accessibilityLabel(announcement.accessibilityDate)
                .padding(.bottom, .huiSpaces.space4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .skeletonLoadable()

            Text(announcement.title)
                .huiTypography(.p1)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color.huiColors.text.body)
                .accessibilityLabel(announcement.accessibilityTitle)
                .padding(.bottom, .huiSpaces.space10)
                .padding(.bottom, .huiSpaces.space2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .skeletonLoadable()

            buttonView
                .skeletonLoadable()
        }
        .padding(.huiSpaces.space24)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level5)
        .huiElevation(level: .level4)
    }

    private var buttonView: some View {
        HorizonUI.PrimaryButton(
            String(localized: "Go to announcement", bundle: .horizon),
            type: .darkOutline,
            isSmall: true
        ) {
            onTap(announcement)
        }
        .accessibilityFocused(focusedAnnouncementID, equals: announcement.id)
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
        ), focusedAnnouncementID: $focusState
    ) { _ in }
}
