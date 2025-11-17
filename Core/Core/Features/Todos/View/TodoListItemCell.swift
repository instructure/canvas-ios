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

struct TodoListItemCell: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.viewController) private var viewController

    @ObservedObject var item: TodoItemViewModel
    @Binding var isSwiping: Bool
    let swipeCompletionBehavior: SwipeCompletionBehavior
    let onTap: (_ item: TodoItemViewModel, _ viewController: WeakViewController) -> Void
    let onMarkAsDone: (_ item: TodoItemViewModel) -> Void
    let onSwipeMarkAsDone: (_ item: TodoItemViewModel) -> Void

    init(
        item: TodoItemViewModel,
        swipeCompletionBehavior: SwipeCompletionBehavior,
        onTap: @escaping (TodoItemViewModel, WeakViewController) -> Void,
        onMarkAsDone: @escaping (TodoItemViewModel) -> Void,
        onSwipeMarkAsDone: @escaping (TodoItemViewModel) -> Void,
        isSwiping: Binding<Bool> = .constant(false)
    ) {
        self.item = item
        self.swipeCompletionBehavior = swipeCompletionBehavior
        self.onTap = onTap
        self.onMarkAsDone = onMarkAsDone
        self.onSwipeMarkAsDone = onSwipeMarkAsDone
        self._isSwiping = isSwiping
    }

    var body: some View {
        HStack(spacing: 0) {
            TodoItemContentView(item: item, isCompactLayout: false)

            checkboxButton
                .paddingStyle(.leading, .cellAccessoryPadding)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 8)
        .paddingStyle(.trailing, .standard)
        .background(.backgroundLightest)
        .contentShape(Rectangle())
        .onTapGesture {
            if isSwiping { return }
            onTap(item, viewController)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .accessibilityActions {
            if let label = item.markAsDoneAccessibilityLabel {
                Button(label) {
                    onMarkAsDone(item)
                }
            }
        }
        .swipeAction(
            backgroundColor: item.swipeBackgroundColor,
            completionBehavior: swipeCompletionBehavior,
            isSwiping: $isSwiping,
            onSwipe: { onSwipeMarkAsDone(item) },
            label: { swipeActionView }
        )
    }

    private var swipeActionView: some View {
        HStack(spacing: 12) {
            Text(item.swipeActionText)
                .font(.semibold16, lineHeight: .fit)
            item.swipeActionIcon
                .scaledIcon(size: 24)
        }
        .paddingStyle(.horizontal, .standard)
        .foregroundStyle(Color.textLightest)
    }

    @ViewBuilder
    private var checkboxButton: some View {
        ZStack {
            switch item.markAsDoneState {
            case .notDone:
                InstUI.Checkbox(isSelected: false)
            case .loading:
                ProgressView().tint(nil)
            case .done:
                InstUI.Checkbox(isSelected: true)
            }
        }
        .frame(width: 44, height: 44)
        .tint(Color(Brand.shared.primary))
        .contentShape(Rectangle())
        .onTapGesture {
            if isSwiping { return }
            onMarkAsDone(item)
        }
        .identifier("to-do.list.\(item.plannableId).checkbox")
    }

}

#if DEBUG

#Preview {
    VStack(spacing: 0) {
        TodoListItemCell(
            item: .makeShortText(),
            swipeCompletionBehavior: .reset,
            onTap: { _, _ in },
            onMarkAsDone: { _ in },
            onSwipeMarkAsDone: { _ in }
        )
        TodoListItemCell(
            item: .makeLongText(),
            swipeCompletionBehavior: .reset,
            onTap: { _, _ in },
            onMarkAsDone: { _ in },
            onSwipeMarkAsDone: { _ in }
        )
    }
    .background(Color.backgroundLightest)
}

#endif
