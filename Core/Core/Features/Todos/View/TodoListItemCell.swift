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
    let onTap: (_ item: TodoItemViewModel, _ viewController: WeakViewController) -> Void
    let onMarkAsDone: (_ item: TodoItemViewModel) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button {
                onTap(item, viewController)
            } label: {
                HStack(spacing: 0) {
                    TodoItemContentView(item: item, isCompactLayout: false)

                    checkboxButton
                        .paddingStyle(.leading, .cellAccessoryPadding)
                }
                .padding(.vertical, 8)
                .background(.backgroundLightest)
            }
            .accessibilityElement(children: .combine)
            .onSwipe(trailing: swipeActions)
        }
    }

    @ViewBuilder
    private var checkboxButton: some View {
        Button {
            onMarkAsDone(item)
        } label: {
            switch item.markDoneState {
            case .notDone:
                InstUI.Checkbox(isSelected: false)
            case .loading:
                ProgressView()
                    .tint(Color(Brand.shared.primary))
            case .done:
                InstUI.Checkbox(isSelected: true)
            }
        }
        .buttonStyle(.plain)
        .frame(width: 44, height: 44)
        .tint(Color(Brand.shared.primary))
        .identifier("to-do.list.\(item.id).checkbox")
    }

    private var swipeActions: [SwipeModel] {
        [
            SwipeModel(
                id: "done",
                image: { Image.completeLine },
                action: { onMarkAsDone(item) },
                style: SwipeStyle(
                    background: .backgroundSuccess,
                    foregroundColor: .textLightest,
                    slotWidth: 60
                )
            )
        ]
    }
}

#if DEBUG

#Preview {
    VStack(spacing: 0) {
        TodoListItemCell(item: .makeShortText(), onTap: { _, _ in }, onMarkAsDone: { _ in })
        TodoListItemCell(item: .makeLongText(), onTap: { _, _ in }, onMarkAsDone: { _ in })
    }
    .background(Color.backgroundLightest)
}

#endif
