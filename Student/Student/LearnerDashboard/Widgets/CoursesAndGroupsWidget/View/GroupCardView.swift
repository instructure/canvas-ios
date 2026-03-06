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

struct GroupCardView: View {
    @Environment(\.viewController) private var controller
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    @Environment(\.offlineMode) private var offlineMode

    private let viewModel: GroupCardViewModel

    init(viewModel: GroupCardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        DashboardThumbnailCard(
            thumbnail: {
                thumbnail
            },
            labels: {
                contextLabel
                titleLabel
            },
            accessory: {
                messageButton
            },
            isAvailable: offlineMode.isAppOnline,
            action: {
                viewModel.didTapCard(from: controller)
            }
        )
        .accessibilityElement(children: .combine)
        .identifier("Dashboard.GroupCard.cardButton")
    }

    @ViewBuilder
    private var thumbnail: some View {
        Color(viewModel.groupColor)
            .scaledFrame(size: 72, useIconScale: true)
            .overlay(alignment: .bottomLeading) {
                memberCountPill
                    .offset(x: 8, y: -8)
            }
    }

    private var contextLabel: some View {
        Text(viewModel.contextName)
            .font(.regular14, lineHeight: .fit)
            .foregroundStyle(viewModel.groupColor)
            .multilineTextAlignment(.leading)
    }

    private var titleLabel: some View {
        Text(viewModel.title)
            .font(.semibold16, lineHeight: .fit)
            .foregroundStyle(.textDarkest)
            .multilineTextAlignment(.leading)
    }

    @ViewBuilder
    private var memberCountPill: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .fill(.backgroundLightest)
                .scaledFrame(height: 24, useIconScale: true)

            HStack(spacing: 4) {
                Text(viewModel.memberCount)
                    .font(.semibold14, lineHeight: .fit)

                Image.userSolid
                    .scaledIcon(size: 16)
            }
            .padding(.horizontal, 4)
        }
        .foregroundStyle(viewModel.groupColor)
        .fixedSize(horizontal: true, vertical: false)
        .identifier("Dashboard.GroupCard.memberCountPill")
    }

    private var messageButton: some View {
        PrimaryButton(isAvailable: offlineMode.isAppOnline) {
            viewModel.didTapMessageButton(from: controller)
        } label: {
            Image.emailLine
                .scaledIcon()
                .foregroundStyle(.textDark)
                .scaledFrame(height: 72, useIconScale: true) // increases tap area
        }
        .accessibilityLabel(String(localized: "Send message to members", bundle: .student))
        .identifier("Dashboard.GroupCard.messageButton")
    }
}

#if DEBUG

extension GroupCardView {
    static let previewData: [CoursesAndGroupsWidgetGroupItem] = [
        .make(id: "1", title: "Study Group A", contextName: "Introduction to Computer Science", groupColor: .course8, memberCount: 42),
        .make(id: "2", title: .loremIpsumLong, contextName: .loremIpsumLong, groupColor: .course2, memberCount: 999),
        .make(id: "3", title: "The Four Horsemen", contextName: "Advanced Mathematics", groupColor: .course5)
    ]
}

#Preview {
    let environment = PreviewEnvironment()

    PreviewContainer(spacing: 4, horizontalPadding: 16) {
        GroupCardView(viewModel: GroupCardViewModel(
            model: GroupCardView.previewData[0],
            router: environment.router,
            environment: environment
        ))

        GroupCardView(viewModel: GroupCardViewModel(
            model: GroupCardView.previewData[1],
            router: environment.router,
            environment: environment
        ))

        GroupCardView(viewModel: GroupCardViewModel(
            model: GroupCardView.previewData[2],
            router: environment.router,
            environment: environment
        ))
    }
    .background(.backgroundLight)
}

#endif
