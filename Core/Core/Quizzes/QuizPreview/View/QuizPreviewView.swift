//
// This file is part of Canvas.
// Copyright (C) 2023-present  Instructure, Inc.
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

public struct QuizPreviewView: View {
    @ObservedObject private var viewModel: QuizPreviewViewModel

    public init(viewModel: QuizPreviewViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ZStack {
            switch viewModel.state {
            case .loading:
                ProgressView()
                    .progressViewStyle(.indeterminateCircle())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.backgroundLightest)
            case .error:
                InteractivePanda(scene: QuizzesPanda(),
                                 title: viewModel.errorTitle,
                                 subtitle: viewModel.errorDescription)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.backgroundLightest)
            case .data(let launchURL):
                WebView(url: launchURL,
                        features: [.invertColorsInDarkMode, .skipQuizPreviewSummary],
                        canToggleTheme: true)
            }
        }
        .navigationTitle(viewModel.navigationTitle)
    }
}

#if DEBUG

struct QuizPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        QuizPreviewAssembly
            .makePreview(state: .loading)
            .previewDisplayName("Loading")
        QuizPreviewAssembly
            .makePreview(state: .error)
            .previewDisplayName("Error")
        QuizPreviewAssembly
            .makePreview(state: .data(launchURL: URL(string: "https://instructure.com")!))
            .previewDisplayName("WebView")
    }
}

#endif
