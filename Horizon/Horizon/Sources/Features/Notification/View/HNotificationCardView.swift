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

struct HNotificationCardView: View {
    let type: NotificationType
    let courseName: String?
    let title: String
    let date: String
    let isRead: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space8) {
            HStack {
                HorizonUI.StatusChip(title: type.title, style: type.style)
                    .accessibilityLabel("\(type.title) notification type")
                Spacer()
                if !isRead {
                    Circle()
                        .fill(Color.huiColors.surface.inversePrimary)
                        .frame(width: 8, height: 8)
                        .accessibilityLabel("Unread indicator")
                        .accessibilityHidden(false)
                }
            }
            if let courseName {
                Text(courseName)
                    .multilineTextAlignment(.leading)
                    .huiTypography(.p3)
                    .foregroundStyle(Color.huiColors.text.timestamp)
                    .accessibilityLabel("Course: \(courseName)")
            }
            Text(title)
                .huiTypography(.p1)
                .multilineTextAlignment(.leading)
                .foregroundStyle(Color.huiColors.text.body)
                .accessibilityLabel("Title: \(title)")

            Text(date)
                .huiTypography(.p3)
                .foregroundStyle(Color.huiColors.text.timestamp)
                .accessibilityLabel("Date: \(date)")
        }
        .padding(.huiSpaces.space16)
        .huiCornerRadius(level: .level2)
        .huiBorder(
            level: .level1,
            color: Color.huiColors.lineAndBorders.lineStroke,
            radius: HorizonUI.CornerRadius.level2.attributes.radius
        )
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    VStack {
        HNotificationCardView(
            type: .score,
            courseName: "Course Name Lorem Ipsum Dolor Sit Amet Adipising",
            title: "Lorem ipsum dolor sit amet adipiscing elit course-specific announcement text goes here.",
            date: "Today",
            isRead: true
        )
        HNotificationCardView(
            type: .scoreChanged,
            courseName: "Course Name Lorem Ipsum Dolor Sit Amet Adipising",
            title: "Lorem ipsum dolor sit amet adipiscing elit course-specific announcement text goes here.",
            date: "Today",
            isRead: false
        )
        HNotificationCardView(
            type: .announcement,
            courseName: "Course Name Lorem Ipsum Dolor Sit Amet Adipising",
            title: "Lorem ipsum dolor sit amet adipiscing elit course-specific announcement text goes here.",
            date: "Today",
            isRead: true
        )
        HNotificationCardView(
            type: .dueDate,
            courseName: "Course Name Lorem Ipsum Dolor Sit Amet Adipising",
            title: "Lorem ipsum dolor sit amet adipiscing elit course-specific announcement text goes here.",
            date: "Today",
            isRead: false
        )
    }
    .padding()
}

enum NotificationType {
    case score
    case scoreChanged
    case dueDate
    case announcement

    var title: String {
        switch self {
        case .score:
            return String(localized: "Scores", bundle: .horizon)
        case .scoreChanged:
            return String(localized: "Score changed", bundle: .horizon)
        case .dueDate:
            return String(localized: "Due date", bundle: .horizon)
        case .announcement:
            return String(localized: "Announcement", bundle: .horizon)
        }
    }

    var style: HorizonUI.StatusChip.Style {
        switch self {
        case .score, .scoreChanged: .violet
        case .dueDate: .honey
        case .announcement: .sky
        }
    }
}
