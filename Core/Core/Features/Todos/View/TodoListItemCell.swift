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

    let item: TodoItem
    let onTap: (_ item: TodoItem, _ viewController: WeakViewController) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Button {
                onTap(item, viewController)
            } label: {
                HStack(spacing: 0) {
                    TodoItemContentView(item: item, isCompactLayout: false)
                    InstUI.DisclosureIndicator()
                        .paddingStyle(.leading, .cellAccessoryPadding)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .combine)
        }
    }
}

#if DEBUG

#Preview {
    VStack(spacing: 0) {
        TodoListItemCell(item: .makeShortText(), onTap: { _, _ in })
        TodoListItemCell(item: .makeLongText(), onTap: { _, _ in })
    }
    .background(Color.backgroundLightest)
}

#endif
