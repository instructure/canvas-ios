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
    @State private var isSettingsPresented = false
    @Environment(\.viewController) private var viewController
    @Environment(\.appEnvironment) private var env
    @Environment(\.colorScheme) private var colorScheme

    private let screenPadding = AUI.Styles.Padding.standard
    @State private var isAnimationEnabled = false

    init(
        viewModel: LearnerDashboardViewModel,
        offlineModeViewModel: OfflineModeViewModel = OfflineModeAssembly.makeViewModel()
    ) {
        _viewModel = State(initialValue: viewModel)
        _offlineModeViewModel = StateObject(wrappedValue: offlineModeViewModel)
    }

    var body: some View {
        BaseScreen(
            state: viewModel.state,
            config: viewModel.screenConfig,
            refreshAction: { completion in
                viewModel.refresh(
                    ignoreCache: true,
                    completion: completion
                )
            }
        ) { geometry in
            VStack(spacing: screenPadding.rawValue) {
                ForEach(viewModel.widgets, id: \.id) { widgetViewModel in
                    // This is a workaround for Todo widget's toggle to have the proper color
                    // TODO: Update AcademicUI.Toggle to use tint color instead of accent color
                    let needsAccentColorOverride = widgetViewModel.id == EditableWidgetIdentifier.todo.rawValue

                    if widgetViewModel.shouldRenderWidget {
                        widgetViewModel.makeView()
                            .accentColor(needsAccentColorOverride ? viewModel.mainColor : .brandPrimary)
                            .transition(.fade)
                    }
                }
                if viewModel.showWidgetsTurnedOffPanda {
                    LearnerDashboardAllWidgetsTurnedOffView()
                }

                customizeDashboardButton
            }
            .paddingStyle(.all, screenPadding)
            .animation(isAnimationEnabled ? .dashboardWidget : nil, value: viewModel.widgets.map(\.layoutIdentifier))
            .onFirstAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isAnimationEnabled = true
                }
            }
            .onAppear {
                // trigger a soft-refresh to apply any changes made on pushed screens
                viewModel.refresh(ignoreCache: false)
            }
            .environment(
                \.containerSize,
                CGSize(
                    width: geometry.size.width - 2 * screenPadding.rawValue,
                    height: geometry.size.height - 2 * screenPadding.rawValue
                )
            )
        }
        .tint(viewModel.mainColor)
        .animation(.dashboardWidget, value: viewModel.mainColor)
        .snackBar(viewModel: viewModel.snackBarViewModel)
        .navigationBarDashboard()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                if #available(iOS 26, *) {
                    profileMenuButton
                } else {
                    legacyProfileMenuButton
                }
            }

            ToolbarItem(placement: .topBarTrailing) {
                if #available(iOS 26, *) {
                    iOS26RightNavBarButtons
                } else if #available(iOS 18, *) {
                    iOS18RightNavBarButtons
                } else {
                    iOS17RightNavBarButtons
                }
            }
        }
    }

    private var customizeDashboardButton: some View {
        Button {
            isSettingsPresented = true
        } label: {
            AUI.PillContent(
                title: String(localized: "Customize Dashboard", bundle: .student),
                leadingIcon: .editLine,
                size: .height30
            )
        }
        .buttonStyle(.pillTintOutlined)
        .identifier("Dashboard.bottomSettingsButton")
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
    @available(iOS, introduced: 26, message: "Multiple versions exists")
    private var iOS26RightNavBarButtons: some View {
        Group {
            if offlineModeViewModel.isOfflineFeatureEnabled {
                DashboardOptionsMenu(
                    offlineModeViewModel: offlineModeViewModel,
                    onSettingsTapped: { isSettingsPresented.toggle() },
                    environment: env
                )
            } else {
                DashboardSettingsButton(
                    onTapped: { isSettingsPresented.toggle() }
                )
            }
        }
        .popover(isPresented: $isSettingsPresented, content: popverContent)
    }

    @ViewBuilder
    @available(iOS, deprecated: 26, message: "Multiple versions exists")
    private var iOS18RightNavBarButtons: some View {
        Group {
            if offlineModeViewModel.isOfflineFeatureEnabled {
                DashboardOptionsButton(
                    isShowingDialog: $isShowingKebabDialog,
                    offlineModeViewModel: offlineModeViewModel,
                    onSettingsTapped: { isSettingsPresented.toggle() },
                    environment: env
                )
            } else {
                LegacyDashboardSettingsButton(
                    onTapped: { isSettingsPresented.toggle() }
                )
            }
        }
        .popover(isPresented: $isSettingsPresented, content: popverContent)
    }

    @ViewBuilder
    @available(iOS, deprecated: 18, message: "Multiple versions exist")
    private var iOS17RightNavBarButtons: some View {
        Group {
            if offlineModeViewModel.isOfflineFeatureEnabled {
                DashboardOptionsButton(
                    isShowingDialog: $isShowingKebabDialog,
                    offlineModeViewModel: offlineModeViewModel,
                    onSettingsTapped: { isSettingsPresented.toggle() },
                    environment: env
                )
            } else {
                LegacyDashboardSettingsButton(
                    onTapped: { isSettingsPresented.toggle() }
                )
            }
        }
        .sheet(isPresented: $isSettingsPresented, content: popverContent)
    }

    @ViewBuilder
    private func popverContent() -> some View {
        // NavigationStack is needed to add content to the toolbar
        NavigationStack {
            LearnerDashboardSettingsScreen(viewModel: viewModel.makeSettingsViewModel())
        }
        .environment(\.colorScheme, colorScheme)
        .accentColor(.brandPrimary)
        .tint(.brandPrimary)
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
