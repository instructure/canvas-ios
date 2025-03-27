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
import Core
import WebKit

struct HEmbeddedWebPageContainerView: View {
    @Environment(\.viewController) private var viewController
    private var features: [CoreWebViewFeature] = [
//        .disableZoom,
//        .forceDisableHorizontalScroll,
        .pullToRefresh(color: UIColor(Color.huiColors.surface.institution))
    ]

    // MARK: - Dependencies

    private let viewModel: HEmbeddedWebPageContainerViewModel

    init(
        viewModel: HEmbeddedWebPageContainerViewModel,
        features: [CoreWebViewFeature] = []
    ) {
        self.viewModel = viewModel
        self.features.append(contentsOf: features)
    }

    var body: some View {
        if let url = viewModel.url {
            contentView(url: url)
                .navigationBarTitleView(title: viewModel.navTitle, subtitle: nil)
                .toolbar(.hidden)
        }
    }

    private func contentView(url: URL) -> some View {
        WebSession(url: viewModel.url) { sessionURL in
            WebView(
                url: sessionURL,
                features: features,
                canToggleTheme: true,
                configuration: .defaultConfiguration
            )
            .onLink { url in
                viewModel.openURL(url, viewController: viewController)
                return true
            }
            .onProvisionalNavigationStarted { webView, navigation in
                viewModel.webView(
                    webView,
                    didStartProvisionalNavigation: navigation
                )
            }
        }
    }
}
