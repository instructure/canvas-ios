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

import Core
import HorizonUI
import SwiftUI

struct NotificationSettingsView: View {
    @Bindable var viewModel: NotificationSettingsViewModel
    @Environment(\.viewController) private var viewController

    var body: some View {
        ZStack {
            Color.huiColors.surface.pagePrimary.edgesIgnoringSafeArea(.all)
            ScrollView {
                entries
                    .padding([.leading, .top, .trailing], 32)
                    .background(Color.white)
            }
            .background(.white)
            .huiCornerRadius(level: .level5, corners: [.topRight, .topLeft])
        }
        .safeAreaInset(edge: .top, spacing: .zero) { navigationBar }
        .background(Color.huiColors.surface.pagePrimary)
    }

    private var entries: some View {
        VStack(spacing: 32) {
            entry(
                title: String(
                    localized: "Announcements and Messages",
                    bundle: .horizon
                ),
                subtitle: String(
                    localized: "Get a notification anytime you receive a course announcement or a new message.",
                    bundle: .horizon
                ),
                isEmailOn: $viewModel.isMessagesEmailEnabled,
                isPushNotificationOn: $viewModel.isMessagesPushEnabled
            )
            entry(
                title: String(
                    localized: "Assignment due dates",
                    bundle: .horizon
                ),
                subtitle: String(
                    localized: "Get a notification anytime an assignment’s due date is added or changed.",
                    bundle: .horizon
                ),
                isEmailOn: $viewModel.isDueDatesEmailEnabled,
                isPushNotificationOn: $viewModel.isDueDatesPushEnabled
            )
            entry(
                title: String(
                    localized: "Scores",
                    bundle: .horizon
                ),
                subtitle: String(
                    localized: "Get a notification anytime an assignment is scored or the score is changed, and anytime the score weight is changed.",
                    bundle: .horizon
                ),
                isEmailOn: $viewModel.isScoreEmailEnabled,
                isPushNotificationOn: $viewModel.isScorePushEnabled
            )
        }
    }

    private var navigationBar: some View {
        ZStack {
            Text("Notifications")
                .huiTypography(.h3)
                .foregroundStyle(Color.huiColors.text.title)
                .frame(height: 44)
                .frame(maxWidth: .infinity, alignment: .center)
            HStack(spacing: 0) {
                HorizonUI.IconButton(
                    HorizonUI.icons.arrowBack,
                    type: .beige,
                    isSmall: false
                ) {
                    viewModel.navigateBack(viewController: viewController)
                }
                .frame(width: 44, height: 44)
                .padding(.leading, .huiSpaces.primitives.medium)
                Spacer()
            }
        }
        .padding(.bottom, .huiSpaces.primitives.xSmall)
    }

    @ViewBuilder
    private func entry(
        title: String,
        subtitle: String,
        isEmailOn: Binding<Bool>,
        isPushNotificationOn: Binding<Bool>
    ) -> some View {
        VStack(alignment: .leading, spacing: .huiSpaces.primitives.xSmall) {
            VStack(alignment: .leading, spacing: .huiSpaces.primitives.xxSmall) {
                Text(title)
                    .huiTypography(.labelLargeBold)
                    .foregroundStyle(Color.huiColors.text.body)

                Text(subtitle)
                    .huiTypography(.p2)
                    .foregroundStyle(Color.huiColors.text.body)
            }
            VStack(alignment: .leading, spacing: .huiSpaces.primitives.xxSmall) {
                HorizonUI.Controls.ToggleItem(
                    isOn: isEmailOn,
                    title: String(localized: "E-mail", bundle: .horizon)
                )
                .padding(.vertical, .huiSpaces.primitives.smallMedium)
                HorizonUI.Controls.ToggleItem(
                    isOn: isPushNotificationOn,
                    title: String(localized: "Push notification", bundle: .horizon)
                )
                .padding(.vertical, .huiSpaces.primitives.smallMedium)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
#Preview {
    NotificationSettingsAssembly.makePreview()
}
#endif
