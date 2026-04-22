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

import Core
import SwiftUI

struct ToDoWidgetListView: View {
    @Environment(\.viewController) private var viewController

    let viewModel: ToDoWidgetListViewModel
    @AccessibilityFocusState var isFirstItemFocused: Bool

    @State private var swipingItemId: String?

    var body: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.items) { item in
                TodoListItemCell(
                    item: item,
                    onTap: { item, vc in viewModel.didTapItem(item, vc) },
                    onMarkAsDone: { viewModel.markItemAsDone($0) },
                    onSwipe: { viewModel.handleSwipeAction($0) },
                    onSwipeCommitted: { viewModel.handleSwipeCommitted($0) },
                    isSwiping: isSwipingBinding(for: item),
                    showCompletedOverride: viewModel.showCompleted
                )
                .identifier("Dashboard.Todo.TodoList.Item")
                .paddingStyle(.leading, .standard)
                .accessibilityFocused($isFirstItemFocused, when: item == viewModel.items.first)

                AUI.Divider(.padded)
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(.format(accessibilityListCount: viewModel.items.count))
    }

    private func isSwipingBinding(for item: TodoItemViewModel) -> Binding<Bool> {
        Binding(
            get: { swipingItemId == item.id },
            set: { isSwiping in swipingItemId = isSwiping ? item.id : nil }
        )
    }
}
