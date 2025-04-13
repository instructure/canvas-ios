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
import WidgetKit

struct TodoItemView: View {
    var body: some View {
        Link(destination: item.route) {
            HStack {
                Text(item.name)
                    .lineLimit(2)
                    .font(.bold17)
                    .foregroundStyle(item.color)
                Spacer()
                Text(item.dueText)
                    .lineLimit(2)
                    .font(.semibold16)
                    .foregroundStyle(Color.textDarkest)
                    .multilineTextAlignment(.trailing)
            }.fixedSize(horizontal: false, vertical: true)
        }
    }

    private let item: TodoItem

    init(item: TodoItem) {
        self.item = item
    }
}

#if DEBUG
struct ToDoItemViewPreview: PreviewProvider {
    static var previews: some View {
        TodoItemView(item: TodoItem(name: "Long Test Assignment Name To Test Line Break", dueAt: Date().addDays(1), color: .textInfo))
    }
}
#endif
