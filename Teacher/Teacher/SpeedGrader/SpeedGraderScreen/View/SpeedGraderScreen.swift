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

import Combine
import Core
import SwiftUI

/// The SpeedGrader screen itself: the container for the `SpeedGraderPage`s representing each student's submission.
/// It displays the navigaton bar and handles paging.
struct SpeedGraderScreen: View, ScreenViewTrackable {
    var screenViewTrackingParameters: ScreenViewTrackingParameters

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.viewController) private var controller
    @StateObject private var viewModel: SpeedGraderScreenViewModel
    @ScaledMetric private var uiScale: CGFloat = 1

    private let screenConfig = InstUI.BaseScreenConfig(
        refreshable: false,
        scrollBounce: .basedOnSize,
        emptyPandaConfig: .init(
            scene: SpacePanda(),
            title: String(localized: "No Submissions", bundle: .teacher),
            subtitle: String(localized: "It seems there aren't any valid submissions to grade.", bundle: .teacher)
        )
    )

    init(viewModel: SpeedGraderScreenViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.screenViewTrackingParameters = viewModel.screenViewTrackingParameters
    }

    var body: some View {
        if #available(iOS 26, *) {
            InstUI.BaseScreen(state: viewModel.state, config: screenConfig) { proxy in
                PagesViewControllerWrapper(
                    dataSource: viewModel,
                    delegate: viewModel,
                    onViewControllerCreate: {
                        viewModel.didShowPagesViewController.send($0)
                    }
                )
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .navigationTitle(viewModel.navigationTitle)
            .navigationSubtitle(viewModel.navigationSubtitle)
            .toolbar {
                if viewModel.isPostPolicyButtonVisible {
                    postPolicySettingsButton
                }
                doneButton
            }
            .onFirstAppear {
                    // When speedgrader is opened from a discussion
                    // the router automatically adds a done button
                controller.value.navigationItem.leadingItemGroups = []
            }
        } else {
            InstUI.BaseScreen(state: viewModel.state, config: screenConfig) { proxy in
                PagesViewControllerWrapper(
                    dataSource: viewModel,
                    delegate: viewModel,
                    onViewControllerCreate: {
                        viewModel.didShowPagesViewController.send($0)
                    }
                )
                .frame(width: proxy.size.width, height: proxy.size.height)
            }
            .navigationBarTitleView(
                title: viewModel.navigationTitle,
                subtitle: viewModel.navigationSubtitle
            )
            // There's an attributed graph cycle (caused by UINavigationBar.useContextColor) that prevents
            // the screen from moving from loading to data state. Adding this ID will treat the view as
            // completely new when the state changes and allowing the view to re-render.
            .id(viewModel.state)
            .navBarItems(trailing: navBarTrailingItems)
            .navigationBarStyle(.color(viewModel.navigationBarColor))
            .onFirstAppear {
                setupStatusBarStyleUpdates()
                // When speedgrader is opened from a discussion
                // the router automatically adds a done button
                controller.value.navigationItem.leadingItemGroups = []
            }
        }
    }

    @available(iOS, deprecated: 26, message: "Toolbars are not colored above iOS 26")
    // Sets the status bar color for the colored toolbar
    private func setupStatusBarStyleUpdates() {
        guard let controller = controller.value as? CoreHostingController<SpeedGraderScreen> else {
            return
        }
        controller.preferredStatusBarStyleOverride = { _ in
            UIUserInterfaceStyle.current == .dark ? .darkContent : .lightContent
        }
    }

    // MARK: - Nav Bar

    private var navBarTrailingItems: some View {
        HStack(spacing: 10) {
            if viewModel.isPostPolicyButtonVisible {
                postPolicySettingsButton
            }
            doneButton
        }
    }

    private var doneButton: InstUI.NavigationBarButton {
        let isBackgroundContextColor = if #available(iOS 26, *) { false } else { true }
        return .done(
            isBackgroundContextColor: isBackgroundContextColor,
            accessibilityId: "SpeedGrader.doneButton"
        ) {
            viewModel.didTapDoneButton.send(controller)
        }
    }

    private var postPolicySettingsButton: some View {
        Button {
            viewModel.didTapPostPolicyButton.send(controller)
        } label: {
            Image.eyeLine
                .size(24 * uiScale.iconScale)
                .foregroundStyleBelow26(.textLightest)
        }
        .identifier("SpeedGrader.postPolicyButton")
        .accessibilityLabel(Text("Post settings", bundle: .teacher))
    }
}

#if DEBUG

#Preview("Loading") {
    SpeedGraderAssembly.makeSpeedGraderViewControllerPreview(state: .loading)
}

#Preview("Error") {
    SpeedGraderAssembly.makeSpeedGraderViewControllerPreview(state: .error(.submissionNotFound))
}

#Preview("Data") {
    SpeedGraderAssembly.makeSpeedGraderViewControllerPreview(state: .data)
}

#endif
