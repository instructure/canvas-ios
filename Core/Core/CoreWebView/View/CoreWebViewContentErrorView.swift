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

struct CoreWebViewContentErrorView: View {
    @StateObject private var viewModel: CoreWebViewContentErrorViewModel

    init(viewModel: @escaping () -> CoreWebViewContentErrorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    InteractivePanda(scene: PagesPanda(),
                                     title: Text("Content Cannot Be Displayed", bundle: .core),
                                     subtitle: Text(viewModel.subtitle))
                    browserButton
                }
                .frame(minHeight: geometry.size.height)
            }
            .frame(maxWidth: .infinity)
        }
    }

    @ViewBuilder
    private var browserButton: some View {
        if viewModel.shouldDisplayOpenInBrowserButton {
            Button(action: viewModel.openInBrowserButtonTapped) {
                Text("Open In Browser", bundle: .core)
                    .padding(12)
                    .background(Color(Brand.shared.buttonPrimaryBackground))
                    .foregroundColor(Color(Brand.shared.buttonPrimaryText))
                    .cornerRadius(4)
            }
            .padding(.top, 30)
        }
    }
}

#if DEBUG

struct CoreWebViewContentErrorView_Previews: PreviewProvider {
    static var previews: some View {
        CoreWebViewContentErrorView {
            CoreWebViewContentErrorViewModel(urlToOpenInBrowser: .stub)
        }
        CoreWebViewContentErrorView {
            CoreWebViewContentErrorViewModel(urlToOpenInBrowser: nil)
        }
    }
}

#endif
