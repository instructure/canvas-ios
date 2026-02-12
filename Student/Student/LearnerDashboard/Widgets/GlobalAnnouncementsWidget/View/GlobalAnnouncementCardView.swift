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
import SwiftUI

struct GlobalAnnouncementCardView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @State var viewModel: GlobalAnnouncementCardViewModel

    var body: some View {
        Button(action: { viewModel.didTapCard() }) {
            HStack(alignment: .top, spacing: 8) {
                icon
                    .alignmentGuide(.top) { $0[.top] - 4 } // to match .leading
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 2) {
                    contextNameLabel

                    if let date = viewModel.date {
                        dateLabel(date)
                    }

                    titleLabel
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .paddingStyle(set: .standardCell)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .elevation(.cardLarge, background: .backgroundLightest)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(viewModel.a11yLabel)
        .identifier("GlobalAnnouncement.\(viewModel.id).card")
    }

    private var icon: some View {
        ZStack {
            Brand.shared.headerImageBackground.asColor

            Brand.shared.headerImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .accessibilityHidden(true)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .scaledFrame(size: 32, useIconScale: true)
        .overlay(alignment: .topLeading) {
            TypeBadge(iconType: viewModel.iconType)
                .alignmentGuide(.leading) { $0[HorizontalAlignment.center] + 2 }
                .alignmentGuide(.top) { $0[VerticalAlignment.center] - 1 }
        }
    }

    private var contextNameLabel: some View {
        Text("Global Announcement", bundle: .student)
            .font(.regular12, lineHeight: .fit)
            .foregroundStyle(.brandPrimary)
    }

    private func dateLabel(_ date: String) -> some View {
        Text(date)
            .font(.regular12, lineHeight: .fit)
            .foregroundStyle(.textDark)
    }

    private var titleLabel: some View {
        Text(viewModel.title)
            .font(.semibold16, lineHeight: .fit)
            .foregroundStyle(.textDarkest)
            .multilineTextAlignment(.leading)
    }
}

// Extracted because some icons are Line, some are Solid.
private struct TypeBadge: View, Equatable {
    let iconType: AccountNotificationIcon

    var body: some View {
        image
            .scaledIcon(size: imageSize)
            .foregroundStyle(foregroundColor)
            .background {
                Circle()
                    .fill(backgroundColor)
                    .stroke(.textLightest, lineWidth: 1)
                    .scaledFrame(size: 14, useIconScale: true)
            }
    }

    private var image: Image {
        switch iconType {
        case .calendar: .calendarMonthLine
        case .information: .infoSolid
        case .question: .questionSolid
        case .warning: .warningSolid
        case .error: .warningSolid
        }
    }

    private var imageSize: CGFloat {
        switch iconType {
        case .calendar: 8
        default: 15
        }
    }

    private var foregroundColor: Color {
        switch iconType {
        case .calendar: .textLightest
        case .information: .textInfo
        case .question: .textInfo
        case .warning: .textWarning
        case .error: .textDanger
        }
    }

    private var backgroundColor: Color {
        switch iconType {
        case .calendar: .textInfo
        default: .textLightest
        }
    }
}

#if DEBUG

private func makeViewModel(
    id: String,
    title: String,
    icon: AccountNotificationIcon = .information,
    startDate: Date? = Date()
) -> GlobalAnnouncementCardViewModel {
    .init(
        model: .make(
            id: id,
            title: title,
            icon: icon,
            startDate: startDate
        ),
        router: PreviewEnvironment().router,
        onMarkAsRead: { _ in }
    )
}

#Preview {
    PreviewContainer {
        VStack(spacing: 16) {
            GlobalAnnouncementCardView(
                viewModel: makeViewModel(id: "1", title: "Calendar", icon: .calendar)
            )

            GlobalAnnouncementCardView(
                viewModel: makeViewModel(id: "2", title: "Info", icon: .information)
            )

            GlobalAnnouncementCardView(
                viewModel: makeViewModel(id: "3", title: "Question", icon: .question)
            )

            GlobalAnnouncementCardView(
                viewModel: makeViewModel(id: "4", title: "Warning", icon: .warning)
            )

            GlobalAnnouncementCardView(
                viewModel: makeViewModel(id: "5", title: "Error", icon: .error)
            )
        }
        .padding(.horizontal, 16)
    }
}

#endif
