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

public struct EmbeddedWebPageView<ViewModel: EmbeddedWebPageViewModel>: View {
    @ObservedObject private var viewModel: ViewModel
    private let isPullToRefreshEnabled: Bool

    public init(
        viewModel: ViewModel,
        isPullToRefreshEnabled: Bool
    ) {
        self.viewModel = viewModel
        self.isPullToRefreshEnabled = isPullToRefreshEnabled
    }

    public var body: some View {
        WebSession(url: viewModel.url) { sessionURL in
            WebView(
                url: sessionURL,
                customUserAgentName: nil,
                disableZoom: true,
                pullToRefresh: isPullToRefreshEnabled ? .enabled(color: viewModel.contextColor) : .disabled
            )
        }
        .navigationTitle(viewModel.navTitle, subtitle: viewModel.subTitle)
        .navigationBarStyle(.color(viewModel.contextColor))
    }
}
