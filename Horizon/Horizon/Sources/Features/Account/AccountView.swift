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
    enum SettingIDs: String {
        case profile
        case notifications
        case advanced
        case reportBug
    }

    // MARK: - Propertites a11y
    @State private var lastFocusedId: String?

    @AccessibilityFocusState private var focusedSettingID: String?

    @Bindable var viewModel: AccountViewModel
    @Environment(\.viewController) private var viewController

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(viewModel.name)
                        .huiTypography(.h1)
                        .foregroundStyle(Color.huiColors.text.title)

                    if viewModel.isExperienceSwitchAvailable {
                        experienceSection
                            .padding(.top, .huiSpaces.space40)
                    }

                    settingsSection
                        .padding(.top, .huiSpaces.space24)

                    helpSection
                        .padding(.top, .huiSpaces.space40)

                    logoutRow
                        .padding(.top, .huiSpaces.space40)
                }
                .padding(.huiSpaces.space24)
            }
            .toolbar(.hidden)
            .background(Color.huiColors.surface.pagePrimary)
            .onAppear {
                guard let lastFocusedId else { return }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    focusedSettingID = lastFocusedId
                }
            }
            .onChange(of: viewModel.onReportBugDismissed) { _, newValue in
                if newValue {
                    guard let lastFocusedId else { return }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        focusedSettingID = lastFocusedId
                        viewModel.onReportBugDismissed = false
                    }
                }
            }
            .huiToast(
                viewModel: .init(
                    text: String(localized: "Your ticket was submitted."),
                    style: .success
                ),
                isPresented: $viewModel.isBugSubmitted
            )

            if viewModel.isLoading {
                loaderView
            }
        }
        .confirmationAlert(
            isPresented: $viewModel.isShowingLogoutConfirmationAlert,
            presenting: viewModel.confirmLogoutViewModel
        )
    }

    private var loaderView: some View {
        ZStack {
            Color.huiColors.surface.pageSecondary
                .opacity(0.6)
            HorizonUI.Spinner(size: .small, showBackground: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }

    private var experienceSection: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space12) {
            Text("Experience")
                .huiTypography(.h3)
                .foregroundStyle(Color.huiColors.text.title)
                .accessibilityAddTraits(.isHeader)

            AccountEntryRowView(
                title: String(localized: "Switch to Canvas Academic", bundle: .horizon),
                image: .huiIcons.swapHoriz,
                isFirstItem: true,
                isLastItem: true,
                didTapRow: {
                    viewModel.switchExperienceDidTap()
                }
            )
        }
    }

    private var settingsSection: some View {
        VStack(alignment: .leading, spacing: .huiSpaces.space12) {
            Text("Settings")
                .huiTypography(.h3)
                .foregroundStyle(Color.huiColors.text.title)
                .accessibilityAddTraits(.isHeader)

            VStack(spacing: .zero) {
                AccountEntryRowView(
                    title: String(localized: "Profile", bundle: .horizon),
                    isFirstItem: true,
                    didTapRow: {
                        lastFocusedId = SettingIDs.profile.rawValue
                        viewModel.profileDidTap(viewController: viewController)
                    }
                )
                .accessibilityFocused($focusedSettingID, equals: SettingIDs.profile.rawValue)
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
                        lastFocusedId = SettingIDs.notifications.rawValue
                        viewModel.notificationsDidTap(viewController: viewController)
                    }
                )
                .accessibilityFocused($focusedSettingID, equals: SettingIDs.notifications.rawValue)
                divider
                AccountEntryRowView(
                    title: String(localized: "Advanced", bundle: .horizon),
                    isLastItem: true,
                    didTapRow: {
                        lastFocusedId = SettingIDs.advanced.rawValue
                        viewModel.advancedDidTap(viewController: viewController)
                    }
                )
                .accessibilityFocused($focusedSettingID, equals: SettingIDs.advanced.rawValue)
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

    private var helpSection: some View {
        VStack(spacing: .zero) {
            Text("Help")
                .huiTypography(.h3)
                .foregroundStyle(Color.huiColors.text.title)
                .accessibilityAddTraits(.isHeader)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, .huiSpaces.space12)

            ForEach(viewModel.helpItems) { item in
                AccountEntryRowView(
                    title: item.title,
                    image: item.isBugReport ? nil : .huiIcons.openInNew,
                    isFirstItem: item == viewModel.helpItems.first,
                    isLastItem: item == viewModel.helpItems.last,
                    didTapRow: {
                        lastFocusedId = item.id
                        viewModel.giveFeedbackDidTap(viewController: viewController, help: item)
                    }
                )
                .accessibilityFocused($focusedSettingID, equals: item.id)
                .accessibilityHint(item.isBugReport
                                   ? String(localized: "Opens form to report a bug", bundle: .horizon)
                                   : String(localized: "Opens in browser", bundle: .horizon))
                divider
                    .hidden(item == viewModel.helpItems.last)
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
    private let image: Image?
    private let didTapRow: () -> Void
    private var cornerRadiusLevel: HorizonUI.CornerRadius = .level2
    private let roundedCorners: HorizonUI.Corners?

    init(
        title: String,
        image: Image? = .huiIcons.arrowForward,
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .multilineTextAlignment(.leading)

                Spacer()

                if let image {
                    image
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.huiColors.icon.medium)
                }
            }
            .padding(.all, .huiSpaces.space16)
        }
        .background(Color.huiColors.surface.cardPrimary)
        .huiCornerRadius(level: cornerRadiusLevel, corners: roundedCorners)
    }
}
