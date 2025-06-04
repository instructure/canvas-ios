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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ScaledMetric private var scale: CGFloat = 1

    private let todoList: TodoList

    init(todoList: TodoList) {
        self.todoList = todoList
    }

    var body: some View {
        TodoContentView(
            logoRoute: .todoListRoute,
            content: { listView },
            actionView: {
                RouteActionView(
                    icon: .addSolid,
                    url: .addTodoRoute,
                    accessibilityLabel: String(localized: "Add To-do")
                )
            }
        )
    }

    // MARK: Subviews

    private var listView: some View {
        VStack(spacing: 5) {
            ForEach(todoList.days) { day in
                HStack(alignment: .top, spacing: 8) {
                    TodoDayView(date: day.date)

                    VStack(spacing: 5) {
                        ForEach(day.items) { item in
                            TodoItemView(item: item)

                            if day.items.last != item {
                                InstUI.Divider()
                            }
                        }
                    }
                }

                if todoList.days.last?.id != day.id {
                    InstUI.Divider().padding(.horizontal, 4)
                }
            }
            Spacer(minLength: 0)
        }
        .padding([.top, .leading, .trailing], 10)
        .padding(.bottom, 40 * scale)
        .containerRelativeFrame(.vertical, alignment: .top)
        .overlay(alignment: .bottom) {
            if todoList.isFullList == false {
                ViewFullListButton()
            }
        }
    }
}

// MARK: - Components

struct ViewFullListButton: View {

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.backgroundLightest,
                            Color.backgroundLightest.opacity(0)
                        ]),
                        startPoint: startPoint,
                        endPoint: .top
                    )
                )
            Link(destination: .todoListRoute) {
                Text("View Full List")
                    .font(.regular16)
                    .foregroundStyle(Color.course2)
            }
        }
        .frame(maxHeight: 54)
    }

    private var startPoint: UnitPoint {
        switch dynamicTypeSize {
        case let size where size <= .xxLarge:
            .bottom
        case .xxxLarge:
            .init(x: 0.5, y: 0.8)
        case .accessibility1, .accessibility2:
            .init(x: 0.5, y: 0.5)
        case let size where size >= .accessibility3:
            .init(x: 0.5, y: 0.4)
        default:
            .bottom
        }
    }
}

// MARK: - Previews

#if DEBUG

#Preview("TodoWidgetData", as: .systemMedium) {
    TodoWidget()
} timeline: {
    TodoWidgetEntry(data: TodoModel.make(), date: Date())
}

#Preview("TodoWidgetData", as: .systemLarge) {
    TodoWidget()
} timeline: {
    TodoWidgetEntry(data: TodoModel.make(count: 7), date: Date())
}

#endif
