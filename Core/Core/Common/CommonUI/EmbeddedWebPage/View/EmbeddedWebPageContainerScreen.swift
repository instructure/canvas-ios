//
// This file is part of Canvas.
// Copyright (C) 2022-present  Instructure, Inc.
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

public struct EmbeddedWebPageContainerScreen: View {
    @ObservedObject private var viewModel: EmbeddedWebPageContainerViewModel
    @Environment(\.viewController) private var viewController
    private var features: [CoreWebViewFeature] = [
        .disableZoom,
        .darkModeForWebDiscussions,
        .forceDisableHorizontalScroll,
        .hidePeerReviewLinkInWebDiscussions
    ]

    public init(
        viewModel: EmbeddedWebPageContainerViewModel,
        isPullToRefreshEnabled: Bool
    ) {
        self.viewModel = viewModel

        if isPullToRefreshEnabled {
            features.append(.pullToRefresh(color: viewModel.contextColor))
        }
    }

    public var body: some View {
        WebSession(url: viewModel.url) { sessionURL in
            WebView(
                url: sessionURL,
                features: features,
                canToggleTheme: true,
                configuration: viewModel.webViewConfig
            )
            .onProvisionalNavigationStarted { webView, navigation in
                viewModel.webView(webView, didStartProvisionalNavigation: navigation)
            }
            .navBarItems(leading: viewModel.leadingNavigationButton)
            .onAppear {
                viewModel.viewController = viewController.value
            }
        }
        .navigationBarTitleView(title: viewModel.navTitle, subtitle: viewModel.subTitle)
        .navigationBarStyle(.color(viewModel.contextColor))
    }
}
