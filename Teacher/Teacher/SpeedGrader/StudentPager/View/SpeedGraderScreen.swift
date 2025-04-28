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

struct SpeedGraderScreen: View {
    @StateObject private var viewModel: SpeedGraderViewModel
    @Environment(\.viewController) private var controller
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    private let screenConfig = InstUI.BaseScreenConfig(
        refreshable: false,
        scrollBounce: .basedOnSize,
        emptyPandaConfig: .init(
            scene: SpacePanda(),
            title: String(localized: "No Submissions", bundle: .teacher),
            subtitle: String(localized: "It seems there aren't any valid submissions to grade.", bundle: .teacher)
        )
    )

    init(
        viewModel: SpeedGraderViewModel
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        InstUI.BaseScreen(state: viewModel.state, config: screenConfig) { proxy in
            PagesViewControllerWrapper(
                dataSource: viewModel,
                delegate: viewModel
            )
            .introspect {
                viewModel.didShowPagesViewController.send($0)
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .navigationBarTitleView(
            title: viewModel.navigationTitle,
            subtitle: viewModel.navigationSubtitle
        )
        .navigationBarStyle(.color(viewModel.navigationBarColor))
        .navBarItems(trailing: navBarTrailingItems)
    }

    private var navBarTrailingItems: some View {
        HStack(spacing: 10) {
            if viewModel.isPostPolicyButtonVisible {
                postPolicySettingsButton
            }
            doneButton
        }
    }

    private var doneButton: InstUI.NavigationBarButton {
        .done(
            isBackgroundContextColor: true,
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
                .foregroundColor(.textLightest)
        }
        .identifier("SpeedGrader.postPolicyButton")
        .accessibility(label: Text("Post settings", bundle: .teacher))
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
