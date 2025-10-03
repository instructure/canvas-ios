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

    init(viewModel: HNotificationViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
       ZStack {
           Color.huiColors.surface.pagePrimary
               .ignoresSafeArea()
            VStack(spacing: .huiSpaces.space8) {
                ScrollView(showsIndicators: false) {
                    contentView
                        .padding(.vertical, .huiSpaces.space16)
                }
                .accessibilityLabel("Notifications list")
            }
            .overlay { loaderView }
            .toolbar(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.huiColors.surface.pageSecondary)
            .huiCornerRadius(level: .level4, corners: [.topLeft, .topRight])
            .padding(.top, .huiSpaces.space16)
            .refreshable {
                await viewModel.refresh()
            }
            .safeAreaInset(edge: .top, spacing: .zero) { navigationBar }
        }
    }

    private var contentView: some View {
        VStack(spacing: .huiSpaces.space8) {
            if viewModel.notifications.isEmpty {
                Text("No notification activity yet.", bundle: .horizon)
                    .foregroundStyle(Color.huiColors.text.body)
                    .huiTypography(.p1)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(.huiSpaces.space24)
                    .padding(.top, .huiSpaces.space24)
                    .accessibilityLabel("No notification activity yet")
            } else {
                ForEach(viewModel.notifications) { activity in
                    Button {
                        viewModel.navigeteToDetails(
                            notification: activity,
                            viewController: viewController
                        )
                    } label: {
                        HNotificationCardView(
                            type: activity.type,
                            courseName: activity.courseName,
                            title: activity.title,
                            date: activity.dateFormatted,
                            isRead: activity.isRead
                        )
                    }
                    .padding(.horizontal, .huiSpaces.space24)
                    .accessibilityHint("Double tap to view details")
                }
                .animation(.linear, value: viewModel.notifications.count)
            }
            if viewModel.isSeeMoreButtonVisible {
                seeMoreButton
                    .padding(.horizontal, .huiSpaces.space24)
            }
        }
    }

    private var navigationBar: some View {
        TitleBar(
            onBack: { _ in dismiss() },
            onClose: nil
        ) {
            Text("Notifications", bundle: .horizon)
                .frame(maxWidth: .infinity)
                .huiTypography(.h3)
                .foregroundStyle(Color.huiColors.text.title)
        }
        .padding(.bottom, .huiSpaces.space16)
        .padding(.horizontal, .huiSpaces.space16)
        .background(Color.huiColors.surface.pagePrimary)
        .accessibilityElement(children: .contain)
    }

    @ViewBuilder
    private var loaderView: some View {
        if viewModel.isLoaderVisible {
            ZStack {
                Color.huiColors.surface.pageSecondary
                    .ignoresSafeArea()
                HorizonUI.Spinner(size: .small, showBackground: true)
                    .accessibilityLabel("Loading notifications")
            }
        }
    }

    private var seeMoreButton: some View {
        Button {
            viewModel.seeMore()
        } label: {
            Text("See More", bundle: .horizon)
                .huiTypography(.buttonTextMedium)
                .foregroundStyle(Color.huiColors.text.title)
                .frame(maxWidth: .infinity)
                .frame(height: 32)
                .huiCornerRadius(level: .level6)
                .huiBorder(
                    level: .level1,
                    color: Color.huiColors.lineAndBorders.lineStroke,
                    radius: HorizonUI.CornerRadius.level6.attributes.radius
                )
        }
        .accessibilityLabel("See More")
        .accessibilityHint("Double tap to load more notifications")
    }
}

#if DEBUG
#Preview {
    NotificationAssembly.makePreview()
}
#endif
