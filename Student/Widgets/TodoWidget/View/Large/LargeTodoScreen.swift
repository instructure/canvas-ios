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

import WidgetKit
import SwiftUI
import Core

struct LargeTodoScreen: BaseTodoScreen {
    var model: TodoModel
    let todoItems: [TodoItem]
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 10) {
                ForEach(todoItems) { item in
                    let itemDueOnSameDateAsPrevious: Bool = todoItems.itemDueOnSameDateAsPrevious(item)
                    let itemDueOnSameDateAsNext: Bool = todoItems.itemDueOnSameDateAsNext(item)
                    TodoItemRow(todoItem: item, itemDueOnSameDateAsPrevious: itemDueOnSameDateAsPrevious)
                    if item != todoItems.last! && !itemDueOnSameDateAsNext {
                        InstUI.Divider()
                    }
                }
                Spacer()
            }
            VStack {
                HStack {
                    Spacer()
                    canvasLogo
                }
                Spacer()
                HStack {
                    ZStack {
                        Text("View Full List")
                            .font(.regular16)
                            .foregroundStyle(Color.purple)
                        HStack {
                            Spacer()
                            addButton
                        }
                    }
                }
            }
        }
    }

    init(model: TodoModel) {
        self.model = model
        self.todoItems = model.todoItems.forLargeTodoScreen
    }
}

#if DEBUG

struct LargeTodoScreenPreviews: PreviewProvider {
    static var previews: some View {
        LargeTodoScreen(model: TodoModel.make())
        .containerBackground(for: .widget) {
            SwiftUI.EmptyView()
        }
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

#endif
