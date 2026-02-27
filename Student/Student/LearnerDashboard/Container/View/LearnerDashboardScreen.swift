//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct LearnerDashboardScreen: View {
    @State private var viewModel: LearnerDashboardViewModel
    @StateObject private var offlineModeViewModel: OfflineModeViewModel
    @State private var isShowingKebabDialog = false
    @Environment(\.viewController) private var viewController
    @Environment(\.appEnvironment) private var env

    init(
        viewModel: LearnerDashboardViewModel,
        offlineModeViewModel: OfflineModeViewModel = OfflineModeAssembly.makeViewModel()
    ) {
        _viewModel = State(initialValue: viewModel)
        _offlineModeViewModel = StateObject(wrappedValue: offlineModeViewModel)
    }

    var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            config: viewModel.screenConfig,
            refreshAction: { completion in
                viewModel.refresh(
                    ignoreCache: true,
                    completion: completion
                )
            }
        ) { geometry in
            DashboardWidgetLayout(
                fullWidthWidgets: viewModel.fullWidthWidgets,
                gridWidgets: viewModel.gridWidgets,
                containerWidth: geometry.size.width
            )
            .paddingStyle(.all, .standard)
        }
        .snackBar(viewModel: viewModel.snackBarViewModel)
        .navigationBarDashboard()
        .toolbar {
            if #available(iOS 26, *) {
                ToolbarItem(placement: .topBarLeading) { profileMenuButton }
                ToolbarItem(placement: .topBarTrailing) { rightNavBarButtons }
            } else {
                ToolbarItem(placement: .topBarLeading) { legacyProfileMenuButton }
                ToolbarItem(placement: .topBarTrailing) { legacyRightNavBarButtons }
            }
        }
    }

    @available(iOS, introduced: 26, message: "Legacy version exists")
    private var profileMenuButton: some View {
        Button {
            env.router.route(to: "/profile", from: viewController, options: .modal())
        } label: {
            Image.hamburgerSolid
        }
        .identifier("Dashboard.profileButton")
        .accessibility(label: Text("Profile Menu, Closed", bundle: .core, comment: "Accessibility text describing the Profile Menu button and its state"))
    }

    @available(iOS, deprecated: 26, message: "Non-legacy version exists")
    private var legacyProfileMenuButton: some View {
        Button {
            env.router.route(to: "/profile", from: viewController, options: .modal())
        } label: {
            Image.hamburgerSolid
                .foregroundColor(Color(Brand.shared.navTextColor))
        }
        .frame(width: 44, height: 44).padding(.leading, -6)
        .identifier("Dashboard.profileButton")
        .accessibility(label: Text("Profile Menu, Closed", bundle: .core, comment: "Accessibility text describing the Profile Menu button and its state"))
    }

    @ViewBuilder
    @available(iOS, introduced: 26, message: "Legacy version exists")
    private var rightNavBarButtons: some View {
        if offlineModeViewModel.isOfflineFeatureEnabled {
            DashboardOptionsMenu(
                offlineModeViewModel: offlineModeViewModel,
                onSettingsTapped: { viewModel.settingsButtonTapped(from: viewController) },
                environment: env
            )
        } else {
            DashboardSettingsButton(
                onTapped: { viewModel.settingsButtonTapped(from: viewController) }
            )
        }
    }

    @ViewBuilder
    @available(iOS, deprecated: 26, message: "Non-legacy version exists")
    private var legacyRightNavBarButtons: some View {
        if offlineModeViewModel.isOfflineFeatureEnabled {
            DashboardOptionsButton(
                isShowingDialog: $isShowingKebabDialog,
                offlineModeViewModel: offlineModeViewModel,
                onSettingsTapped: { viewModel.settingsButtonTapped(from: viewController) },
                environment: env
            )
        } else {
            LegacyDashboardSettingsButton(
                onTapped: { viewModel.settingsButtonTapped(from: viewController) }
            )
        }
    }
}

#if DEBUG

#Preview {
    let controller = CoreHostingController(
        LearnerDashboardAssembly.makeScreen()
    )
    CoreNavigationController(rootViewController: controller)
}

#endif
