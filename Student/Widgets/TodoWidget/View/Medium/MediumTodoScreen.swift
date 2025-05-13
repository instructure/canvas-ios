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

struct MediumTodoScreen: BaseTodoScreen {
    var model: TodoModel
    let todoItems: [TodoItem]
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 10) {
                ForEach(todoItems) { item in
                    TodoItemRow(todoItem: item, itemDueOnSameDateAsPrevious: todoItems.itemDueOnSameDateAsPrevious(item))
                    if item != todoItems.last! {
                        InstUI.Divider()
                    }
                }
            }
            HStack {
                Spacer()
                canvasLogo
            }
        }
    }

    init(model: TodoModel) {
        self.model = model
        self.todoItems = model.todoItems.forMediumTodoScreen
    }
}

#if DEBUG

struct MediumTodoScreenPreviews: PreviewProvider {
    static var previews: some View {
        MediumTodoScreen(model: TodoModel.make())
        .containerBackground(for: .widget) {
            SwiftUI.EmptyView()
        }
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

#endif
