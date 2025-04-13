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

struct SmallTodoView: View {
    var body: some View {
        VStack(spacing: 10) {
            Text("To-Do")
                .font(.semibold12)
                .foregroundColor(.textDark)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(todoItem.name)
                .font(.semibold12)
                .foregroundColor(todoItem.color)
                .frame(maxWidth: .infinity, alignment: .leading)
                .lineLimit(40)
            Text(todoItem.dueText)
                .font(.bold24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.5)
            Spacer(minLength: 0)
        }
        .widgetURL(todoItem.route)
    }

    private let todoItem: TodoItem

    init(todoItem: TodoItem) {
        self.todoItem = todoItem
    }
}

#if DEBUG

struct SmallToDoViewPreviews: PreviewProvider {
    static var previews: some View {
        SmallTodoView(todoItem: TodoItem(name: "Lab 1.2: The Solar System", dueAt: Date().addDays(1), color: .textInfo))
            .containerBackground(for: .widget) {
                SwiftUI.EmptyView()
            }
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

#endif
