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

struct TodoWidgetView: View {
    private let model: TodoModel
    private var firstItem: TodoItem? { model.todoItems.first }
    @Environment(\.widgetFamily)
    private var family
    private let lineCountByFamily: [WidgetFamily: Int] = [
        .systemMedium: 2,
        .systemLarge: 5,
        .systemExtraLarge: 5
    ]

    var body: some View {
        buildView()
            .containerBackground(for: .widget) {
                Color.backgroundLightest
            }
    }

    @ViewBuilder
    private func buildView() -> some View {
        if let firstItem {
            switch family {
            case .systemSmall:
                SmallTodoView(todoItem: firstItem)
            default:
                MediumLargeTodoView(model: model, lineCount: lineCountByFamily[family] ?? 1)
            }
        } else if model.isLoggedIn {
            EmptyView(title: Text("To-Do Items"), message: Text("No To-Do Items To Display"))

        } else {
            EmptyView(title: Text("To-Do Items"), message: Text("Please log in via the application"))
        }
    }

    init(model: TodoModel) {
        self.model = model
    }
}

#if DEBUG

struct ToDoWidgetPreviews: PreviewProvider {
    static var previews: some View {
        let data = TodoModel.make()
        TodoWidgetView(model: data).previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
#endif
