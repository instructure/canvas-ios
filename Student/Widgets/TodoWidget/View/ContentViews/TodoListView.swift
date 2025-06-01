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

    let model: TodoModel

    var body: some View {
        TodoContentView(
            logoRoute: .todoListRoute,
            actionIcon: .addLine,
            actionRoute: .addTodoRoute,
            content: { listView }
        )
        .overlay(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .red]),
                        startPoint: .top,
                        endPoint: .center
                    )
                )

        }
        .ignoresSafeArea()
        .containerBackground(for: .widget) { Color.mint }

    }

    // MARK: Privates

    private var showsFullListButton: Bool {
        model.items.count > family.shownTodoItemsMaximumCount
    }

    private var shownItems: [TodoItem] {
        Array(
            model
                .items
                .sorted { $0.date < $1.date }
                .prefix(family.shownTodoItemsMaximumCount)
        )
    }

    private func isShownLast(_ item: TodoItem) -> Bool {
        guard let index = model.items.firstIndex(of: item) else {
            return false
        }
        let count = min(model.items.count, family.shownTodoItemsMaximumCount)
        return index == (count - 1)
    }

    // MARK: Subviews

    private var listView: some View {
        VStack {
            ForEach(shownItems) { item in
                let itemDueOnSameDateAsPrevious: Bool = model.items.itemDueOnSameDateAsPrevious(item)
                let itemDueOnSameDateAsNext: Bool = model.items.itemDueOnSameDateAsNext(item)

                HStack(alignment: .top, spacing: 5) {
                    TodoItemDate(item: item, itemDueOnSameDateAsPrevious: itemDueOnSameDateAsPrevious)
                    TodoItemDetail(item: item, itemDueOnSameDateAsNext: itemDueOnSameDateAsNext)
                }
                if isShownLast(item) == false && !itemDueOnSameDateAsNext {
                    InstUI.Divider()
                }
            }
            Spacer()
        }
        .overlay(alignment: .bottom) {
            //fullListButtonView
        }
    }

    private var fullListButtonView: some View {
        ZStack {
            if showsFullListButton {
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .backgroundLightest]),
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                Link(destination: .todoListRoute) {
                    Text("View Full List")
                        .font(.regular16)
                        .foregroundStyle(Color.purple)
                }
            }
        }
        .ignoresSafeArea()
        .frame(maxHeight: 32)
    }
}

#if DEBUG

struct TodoScreenPreviews: PreviewProvider {

    static var previews: some View {

        TodoListView(model: TodoModel.make())
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            .previewDisplayName("Medium Size")

        TodoListView(model: TodoModel.make())
            .previewContext(WidgetPreviewContext(family: .systemLarge))
            .previewDisplayName("Large Size")
    }
}

#endif
