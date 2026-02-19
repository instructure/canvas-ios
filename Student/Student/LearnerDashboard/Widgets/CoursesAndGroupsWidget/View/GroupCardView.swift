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

    private let viewModel: GroupCardViewModel
    @StateObject private var offlineModeViewModel = OfflineModeViewModel(interactor: OfflineModeAssembly.make())

    init(viewModel: GroupCardViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        DashboardThumbnailCard(
            thumbnail: {
                thumbnail
            },
            labels: {
                courseLabel
                titleLabel
            },
            isAvailable: !$offlineModeViewModel.isOffline,
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
            .scaledFrame(size: 72)
            .overlay(alignment: .bottomLeading) {
                memberCountPill
                    .offset(x: 8, y: -8)
            }
    }

    private var courseLabel: some View {
        Text(viewModel.courseName)
            .font(.regular14, lineHeight: .fit)
            .foregroundStyle(viewModel.courseColor)
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
        .identifier("Dashboard.CourseCard.gradePill")
    }
}

#if DEBUG

extension GroupCardView {
    static let previewData: [CoursesAndGroupsWidgetGroupItem] = [
        .make(id: "1", title: "Study Group A", courseName: "Introduction to Computer Science", groupColorString: "#4CAF50", memberCount: 42),
        .make(id: "2", title: .loremIpsumLong, courseName: .loremIpsumLong, groupColorString: "#E91E63", memberCount: 999),
        .make(id: "3", title: "The Four Horsemen", courseName: "Advanced Mathematics", groupColorString: "#E91E63")
    ]
}

#Preview {
    PreviewContainer(spacing: 4, horizontalPadding: 16) {
        GroupCardView(viewModel: GroupCardViewModel(
            model: GroupCardView.previewData[0],
            router: PreviewEnvironment().router
        ))

        GroupCardView(viewModel: GroupCardViewModel(
            model: GroupCardView.previewData[1],
            router: PreviewEnvironment().router
        ))

        GroupCardView(viewModel: GroupCardViewModel(
            model: GroupCardView.previewData[2],
            router: PreviewEnvironment().router
        ))
    }
    .background(.backgroundLight)
}

#endif
