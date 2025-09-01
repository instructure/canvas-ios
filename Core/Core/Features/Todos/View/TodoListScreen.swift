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
        InstUI.BaseScreen(
            state: viewModel.state,
            refreshAction: { completion in
                viewModel.refresh(completion: completion, ignoreCache: true)
            }
        ) { _ in
            ForEach(viewModel.items) { item in
                TodoListItemCell(
                    item: item,
                    onTap: viewModel.didTapItem,
                    isLastItem: viewModel.items.last == item
                )
            }
        }
    }
}

#if DEBUG

#Preview {
    let viewModel = TodoListViewModel(interactor: TodoInteractorPreview(), env: PreviewEnvironment())
    TodoListScreen(viewModel: viewModel)
}

#endif
