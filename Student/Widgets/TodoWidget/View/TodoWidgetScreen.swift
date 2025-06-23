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

struct TodoWidgetScreen: View {

    @Environment(\.widgetFamily) private var family
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: TodoModel

    var body: some View {
        content
            .defaultTodoWidgetContainer()
    }

    @ViewBuilder
    private var content: some View {
        if model.isLoggedIn {

            if model.error != nil {
                TodoFailureView()
            } else if model.items.isEmpty {
                TodoEmptyView()
            } else {
                TodoListView(todoList: model.todoDays(for: family))
            }

        } else {

            TodoLoggedoutView()
        }
    }
}

extension View {
    func defaultTodoWidgetContainer() -> some View {
        containerBackground(for: .widget) { Color.backgroundLightest }
    }
}

#if DEBUG

struct TodoWidgetPreviews: PreviewProvider {
    static var previews: some View {
        TodoWidgetScreen(model: TodoModel.make())
            .defaultTodoWidgetContainer()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

#endif
