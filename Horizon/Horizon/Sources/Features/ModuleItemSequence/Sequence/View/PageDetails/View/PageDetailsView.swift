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

    @Environment(\.viewController) private var viewController: WeakViewController
    @State private var viewModel: PageDetailsViewModel

    // MARK: - Init

    init(viewModel: PageDetailsViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack(spacing: .zero) {
            header
            ZStack(alignment: .top) {
                spinner
                page
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }

    @ViewBuilder
    var page: some View {
        if let pageURL = viewModel.pageURL,
           let itemID = viewModel.itemID {
            ZStack(alignment: .bottomTrailing) {
                PageViewRepresentable(
                    isScrollTopReached: $isShowHeader,
                    context: viewModel.context,
                    pageURL: pageURL,
                    itemID: itemID
                )
                if let model = viewModel.markAsDoneViewModel {
                    MarkAsDoneButton(
                        isCompleted: model.isCompleted,
                        isLoading: model.isLoading
                    ) {
                        model.markAsDone()
                    }
                    .padding(.horizontal, .huiSpaces.space24)
                    .padding(.bottom, .huiSpaces.space16)
                    .alert(
                        isPresented: Binding(
                            get: { model.isErrorPresented },
                            set: { _ in model.errorMessage = nil }
                        )
                    ) {
                        Alert(
                            title: Text(model.errorMessage ?? String(localized: "An error occurred while marking as done."))
                        )
                    }
                }
            }
            .preference(key: HeaderVisibilityKey.self, value: isShowHeader)
            .opacity(viewModel.bodyOpacity)
            .animation(.easeInOut, value: viewModel.bodyOpacity)
        }
    }

    @ViewBuilder
    var spinner: some View {
        HorizonUI.Spinner(size: .xSmall)
            .padding(.top, .huiSpaces.space24)
    }

    @ViewBuilder
    var header: some View {
        if viewModel.isHeaderVisible {
            VStack(alignment: .trailing, spacing: .zero) {
                HorizonUI.IconButton(
                    .huiIcons.close,
                    type: .white,
                    isSmall: true
                ) {
                    viewModel.close(viewController: viewController)
                }
            }
            .padding(.horizontal, .huiSpaces.space16)
            .padding(.vertical, .huiSpaces.space8)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color.huiColors.surface.divider),
                alignment: .bottom
            )
        }
    }
}

#if DEBUG
class PageDetailsViewModelPreview: PageDetailsViewModel {
    var context: Core.Context { .init(.course, id: "477") }
    var pageURL: String? { "" }
    var bodyOpacity: Double { 0.0 }
    var isHeaderVisible: Bool { true }
    var loaderOpacity: Double { 1.0 }
    var itemID: String? { "4446" }
    var markAsDoneViewModel: MarkAsDoneViewModel? { nil }

    func close(viewController: WeakViewController) {

    }
}

#Preview {
    PageDetailsView(
        viewModel: PageDetailsViewModelPreview()
    )
}
#endif
