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

public struct TodoListScreen: View {
    @Environment(\.viewController) private var viewController
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ObservedObject var viewModel: TodoListViewModel

    public init(viewModel: TodoListViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        contentView
            .background(.backgroundLightest)
    }

    @ViewBuilder
    private var contentView: some View {
        RefreshableScrollView(showsIndicators: false) {
            if viewModel.hasError {
                errorView
            } else if viewModel.items.isEmpty {
                emptyView
            } else {
                dataView
            }
        } refreshAction: { completion in
            viewModel.refresh(ignoreCache: true, completion: completion)
        }
        .padding(.vertical, 8)

    }

    private var dataView: some View {
        ForEach(viewModel.items, id: \.id) { item in
            VStack(spacing: 0) {
                Button {
                    viewModel.didTapItem(item, viewController)
                } label: {
                    TodoListItemView(item: item)
                        .paddingStyle(set: .iconCell)
                }
                InstUI.Divider(item != viewModel.items.last ? .padded : .full)
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 10) {
            Image("PandaSleeping", bundle: .core)
            Text("Well Done!")
                .foregroundStyle(.textDarkest)
                .font(.bold20)
            Text("Your to do list is empty. Time to recharge.")
                .foregroundStyle(.textDarkest)
                .font(.regular16)
        }
    }

    private var errorView: some View {
        VStack(spacing: 10) {
            Image("PandaNoResults", bundle: .core)
            Text("Something Went Wrong!")
                .foregroundStyle(.textDarkest)
                .font(.bold20)
            Text("Pull to refresh to try again.")
                .foregroundStyle(.textDarkest)
                .font(.regular16)
        }
    }
}

#if DEBUG

#Preview {
    let viewModel = TodoListViewModel(interactor: TodoInteractorPreview(), env: PreviewEnvironment())
    TodoListScreen(viewModel: viewModel)
}

#endif
