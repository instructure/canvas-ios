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

struct TodoListView: View {
    @Environment(\.widgetFamily) private var family

    private let todoList: TodoList

    init(todoList: TodoList) {
        self.todoList = todoList
    }

    var body: some View {
        TodoContentView(
            logoRoute: .todoListRoute,
            actionIcon: .addLine,
            actionRoute: .addTodoRoute,
            content: { listView }
        )
    }

    // MARK: Subviews

    private var listView: some View {
        VStack(spacing: 5) {
            ForEach(todoList.days) { day in
                HStack(alignment: .top, spacing: 10) {
                    TodoItemDate(date: day.date)

                    VStack(spacing: 8) {
                        ForEach(day.items) { item in
                            TodoItemDetail(item: item)

                            if day.items.last != item {
                                InstUI.Divider()
                            }
                        }
                    }
                }

                if todoList.days.last?.id != day.id {
                    InstUI.Divider()
                }
            }
            Spacer(minLength: 0)
        }
        .padding([.top, .leading, .trailing], 10)
        .padding(.bottom, 35)
        .overlay(alignment: .bottom) {
            if todoList.isFullList == false {
                fullListButtonView
            }
        }
    }

    private var fullListButtonView: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.backgroundLightest,
                            Color.backgroundLightest.opacity(0)
                        ]),
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
            Link(destination: .todoListRoute) {
                Text("View Full List")
                    .font(.regular16)
                    .foregroundStyle(Color.purple)
            }
        }
        .ignoresSafeArea()
        .frame(maxHeight: 54)
    }
}

#if DEBUG

struct TodoScreenPreviews: PreviewProvider {

    static var previews: some View {
        let model = TodoModel.make(count: 7)

        TodoListView(todoList: model.todoDays(for: .systemMedium))
            .defaultTodoWidgetContainer()
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium Size")

        TodoListView(todoList: model.todoDays(for: .systemLarge))
            .defaultTodoWidgetContainer()
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .previewDisplayName("Large Size")
    }
}

#endif
