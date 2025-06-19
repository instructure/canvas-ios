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

import SwiftUI
import HorizonUI
import Core

struct HNotificationView: View {
    // MARK: - Private Properties

    @Environment(\.dismiss) private var dismiss
    @Environment(\.viewController) private var viewController

    // MARK: - Dependencies

    private let viewModel: HNotificationViewModel
    private let onShowNavigationBarAndTabBar: (Bool) -> Void

    init(
        viewModel: HNotificationViewModel,
        onShowNavigationBarAndTabBar: @escaping (Bool) -> Void
    ) {
        self.viewModel = viewModel
        self.onShowNavigationBarAndTabBar = onShowNavigationBarAndTabBar
    }

    var body: some View {
        VStack(spacing: .zero) {
            contentView
            Divider()
                .hidden(viewModel.notifications.isEmpty)
            footerView
                .padding(.top, .huiSpaces.space16)
                .frame(maxWidth: .infinity)
                .background(Color.huiColors.surface.pageSecondary)

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.huiColors.surface.pagePrimary)
        .overlay { loaderView }
        .safeAreaInset(edge: .top, spacing: .zero) { navigationBar }
        .onWillDisappear { onShowNavigationBarAndTabBar(true) }
        .onWillAppear { onShowNavigationBarAndTabBar(false) }
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var contentView: some View {
        VStack {
            if viewModel.notifications.isEmpty {
                Text("No notification activity yet.", bundle: .horizon)
                    .foregroundStyle(Color.huiColors.text.body)
                    .huiTypography(.p1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.huiSpaces.space24)
                    .padding(.top, .huiSpaces.space24)
                Spacer()
            } else {
                ScrollView(showsIndicators: false) {
                    ForEach(viewModel.notifications) { activity in
                        Button {
                            viewModel.navigeteToCourseDetails(
                                notification: activity,
                                viewController: viewController
                            )
                        } label: {
                            notificationRow(notification: activity)
                        }
                        Divider()
                            .hidden(activity == viewModel.notifications.last)
                    }
                    .animation(.linear, value: viewModel.notifications)
                }
                .padding(.top, .huiSpaces.space16)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.huiColors.surface.pageSecondary)
        .huiCornerRadius(level: .level4, corners: [.topLeft, .topRight])
        .padding(.top, .huiSpaces.space16)
    }

    private func notificationRow(notification: NotificationModel) -> some View {
        VStack(spacing: .huiSpaces.space4) {
            Text(notification.category)
                .foregroundStyle(Color.huiColors.text.timestamp)
                .huiTypography(.labelSmall)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .top) {
                Text(notification.title)
                    .huiTypography(notification.isRead ? .p1 : .labelLargeBold)
                    .foregroundStyle(Color.huiColors.text.body)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !notification.isRead {
                    Circle()
                        .fill(Color.huiColors.surface.institution)
                        .frame(width: 8, height: 8)
                }
            }

            Text(notification.date)
                .foregroundStyle(Color.huiColors.text.timestamp)
                .huiTypography(.labelSmall)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, .huiSpaces.space16)
        .padding(.horizontal, .huiSpaces.space24)
    }

    private var navigationBar: some View {
        ZStack(alignment: .leading) {
            Text("Notifications", bundle: .horizon)
                .frame(maxWidth: .infinity)
                .huiTypography(.h3)
                .foregroundStyle(Color.huiColors.text.title)

            Button {
                dismiss()
            } label: {
                Image.huiIcons.arrowBack
            }
            .foregroundStyle(Color.huiColors.icon.default)
            .frame(width: 44, height: 44)
        }
        .padding(.horizontal, .huiSpaces.space16)
    }

    @ViewBuilder
    private var loaderView: some View {
        if viewModel.isLoaderVisible {
            ZStack {
                Color.huiColors.surface.pageSecondary
                    .ignoresSafeArea()
                HorizonUI.Spinner(size: .small, showBackground: true)
            }
        }
    }

    private var footerView: some View {
        HStack(spacing: .huiSpaces.space8) {
            HorizonUI.IconButton(Image.huiIcons.chevronLeft, type: .black) {
                viewModel.goPrevious()
            }
            .disabled(!viewModel.isPreviousButtonEnabled)

            HorizonUI.IconButton(Image.huiIcons.chevronRight, type: .black) {
                viewModel.goNext()
            }
            .disabled(!viewModel.isNextButtonEnabled)

        }
        .hidden(viewModel.notifications.isEmpty)
        .padding(.top, .huiSpaces.space10)
    }
}

#if DEBUG
#Preview {
    NotificationAssembly.makePreview()
}
#endif
