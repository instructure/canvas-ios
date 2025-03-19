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
import HorizonUI

struct PageDetailsView: View {
    // MARK: - Private Properties

    @State private var isShowHeader: Bool = true

    // MARK: - Dependencies

    @State private var viewModel: PageDetailsViewModel

    // MARK: - Init

    init(viewModel: PageDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: .zero) {
                topView
                WebView(
                    html: viewModel.content,
                    baseURL: viewModel.url
                )
                .frameToFit()
            }

            if viewModel.isMarkedAsDoneButtonVisible {
                MarkAsDoneButton(
                    isCompleted: viewModel.isCompletedItem,
                    isLoading: viewModel.isMarkAsDoneLoaderVisible
                ) {
                    viewModel.markAsDone()
                }
                .padding(.huiSpaces.space24)
            }
        }
        .overlay { loaderView }
        .preference(key: HeaderVisibilityKey.self, value: isShowHeader)
        .alert(isPresented: $viewModel.isShowErrorAlert) {
            Alert(title: Text(viewModel.errorMessage))
        }
    }

    @ViewBuilder
    private var loaderView: some View {
        if viewModel.isLoaderVisible {
            HorizonUI.Spinner(size: .small, showBackground: true)
        }
    }

    private var topView: some View {
        Color.clear
            .frame(height: 0)
            .readingFrame { frame in
                isShowHeader = frame.minY > -100
            }
    }
}
