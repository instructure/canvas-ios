//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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
import WebKit

public struct K5SubjectView: View, ScreenViewTrackable {
    @Environment(\.appEnvironment) private var env
    @Environment(\.viewController) private var controller

    @ObservedObject private var viewModel: K5SubjectViewModel
    public let screenViewTrackingParameters: ScreenViewTrackingParameters

    private var padding: CGFloat { UIDevice.current.userInterfaceIdiom == .pad ? 32 : 16 }

    public var body: some View {
        VStack(spacing: 0) {
            if let topBarViewModel = viewModel.topBarViewModel {
                TopBarView(viewModel: topBarViewModel, horizontalInset: padding, itemSpacing: padding)
                Divider()
                if UIDevice.current.userInterfaceIdiom == .pad {
                    K5SubjectHeaderView(title: viewModel.courseTitle,
                                        imageUrl: viewModel.courseBannerImageUrl ?? viewModel.courseImageUrl,
                                        backgroundColor: Color(viewModel.courseColor ?? .clear)).padding(padding)
                }
                if let currentPageURL = viewModel.currentPageURL {
                    WebView(url: currentPageURL,
                            features: [
                                .disableZoom,
                                .pullToRefresh(color: viewModel.courseColor),
                                .invertColorsInDarkMode,
                            ],
                            configuration: viewModel.config)
                    .reload(on: viewModel.reloadWebView)
                }
                Divider()
            }
        }
        .navigationBarStyle(.color(self.viewModel.courseColor))
        .navigationTitle(self.viewModel.courseTitle ?? "", subtitle: nil)
    }

    public init(context: Context, selectedTabId: String? = nil) {
        self.viewModel = K5SubjectViewModel(context: context, selectedTabId: selectedTabId)
        self.screenViewTrackingParameters = ScreenViewTrackingParameters(eventName: "\(context.pathComponent)")
        self.controller.value.navigationController?.navigationBar.tintColor = self.viewModel.courseColor
    }
}

struct K5SubjectView_Previews: PreviewProvider {
    static var previews: some View {
        K5SubjectView(context: Context(.course, id: "12345"))
    }
}
