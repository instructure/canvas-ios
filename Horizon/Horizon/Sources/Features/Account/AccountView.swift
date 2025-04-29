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

struct AccountView: View {
    @Bindable var viewModel: AccountViewModel
    @Environment(\.viewController) private var viewController

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.name)
                    .huiTypography(.h1)
                    .foregroundStyle(Color.huiColors.text.title)

                settingsSection
                    .padding(.top, 40)
                supportSection
                    .padding(.top, .huiSpaces.space24)

                logoutRow
                    .padding(.top, 40)
            }
            .padding(.huiSpaces.space24)
        }
        .toolbar(.hidden)
        .background(Color.huiColors.surface.pagePrimary)
        .confirmationAlert(
            isPresented: $viewModel.isShowingLogoutConfirmationAlert,
            presenting: viewModel.confirmLogoutViewModel
        )
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space12) {
            Text("Settings")
                .huiTypography(.h3)
                .foregroundStyle(Color.huiColors.text.title)

            VStack(spacing: 0) {
                AccountEntryRowView(
                    title: String(localized: "Profile", bundle: .horizon),
                    isFirstItem: true,
                    didTapRow: {
                        viewModel.profileDidTap(viewController: viewController)
                    }
                )
                // TODO: Uncomment after implementing the functionality
//                divider
//                AccountEntryRowView(
//                    title: String(localized: "Password", bundle: .horizon),
//                    didTapRow: {
//                        viewModel.passwordDidTap()
//                    }
//                )
                divider
                AccountEntryRowView(
                    title: String(localized: "Notifications", bundle: .horizon),
                    didTapRow: {
                        viewModel.notificationsDidTap(viewController: viewController)
                    }
                )
                divider
                AccountEntryRowView(
                    title: String(localized: "Advanced", bundle: .horizon),
                    isLastItem: true,
                    didTapRow: {
                        viewModel.advancedDidTap(viewController: viewController)
                    }
                )
            }
        }
        .onAppear {
            viewModel.getUserName()
        }

    }

    private var divider: some View {
        Rectangle()
            .fill(Color.huiColors.lineAndBorders.lineStroke)
            .frame(height: 1)
    }

    private var supportSection: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space12) {
            Text("Support")
                .huiTypography(.h3)
                .foregroundStyle(Color.huiColors.text.title)

            VStack(spacing: 0) {                AccountEntryRowView(
                    title: "Give Feedback",
                    image: .huiIcons.openInNew,
                    isFirstItem: true,
                    isLastItem: true,
                    didTapRow: {
                        viewModel.giveFeedbackDidTap(viewController: viewController)
                    }
                )
            }
        }
    }

    private var logoutRow: some View {
        AccountEntryRowView(
            title: "Log Out",
            image: .huiIcons.logout,
            isFirstItem: true,
            isLastItem: true,
            didTapRow: {
                viewModel.logoutDidTap()
            }
        )
    }
}

#if DEBUG
#Preview {
    AccountAssembly.makePreview()
}
#endif

private struct AccountEntryRowView: View {
    private let title: String
    private let image: Image
    private let didTapRow: () -> Void
    private var cornerRadiusLevel: HorizonUI.CornerRadius = .level2
    private let roundedCorners: HorizonUI.Corners?

    init(
        title: String,
        image: Image = .huiIcons.arrowForward,
        isFirstItem: Bool = false,
        isLastItem: Bool = false,
        didTapRow: @escaping () -> Void
    ) {
        self.title = title
        self.image = image

        switch (isFirstItem, isLastItem) {
        case (true, true):
            self.roundedCorners = .all
        case (true, false):
            self.roundedCorners = .top
        case (false, true):
            self.roundedCorners = .bottom
        default:
            self.roundedCorners = nil
            self.cornerRadiusLevel = .level0
        }
        self.didTapRow = didTapRow
    }

    var body: some View {
        Button {
            didTapRow()
        } label: {
            HStack(spacing: 0) {
                Text(title)
                    .huiTypography(.labelLargeBold)
                    .foregroundStyle(Color.huiColors.text.body)
                    .frame(minHeight: 24)

                Spacer()

                image
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.huiColors.icon.medium)
            }
            .padding(.all, .huiSpaces.space16)
        }
        .background(Color.huiColors.surface.cardPrimary)
        .huiCornerRadius(level: cornerRadiusLevel, corners: roundedCorners)
    }
}
