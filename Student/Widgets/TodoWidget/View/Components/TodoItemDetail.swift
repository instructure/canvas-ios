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
import Core

struct TodoItemDetail: View {
    var item: TodoItem
    let itemDueOnSameDateAsNext: Bool

    var body: some View {
        Link(destination: item.route) {
            VStack(alignment: .leading, spacing: 2) {
                contextSection
                titleSection
                timeSection
                if itemDueOnSameDateAsNext {
                    InstUI.Divider()
                        .padding(.top, 3)
                }
            }
        }
    }

    private var contextSection: some View {
        HStack(spacing: 4) {
            if let itemIcon = item.icon {
                itemIcon
                    .size(16)
                    .foregroundStyle(item.color)
                InstUI.Divider()
                    .frame(maxHeight: 16)
            }
            Text(item.contextName)
                .foregroundStyle(item.color)
                .font(.regular12)
        }
    }

    private var titleSection: some View {
        Text(item.title)
            .font(.semibold14)
            .foregroundStyle(Color.textDarkest)
    }

    private var timeSection: some View {
        Text(item.date.formatted(.dateTime.hour().minute()))
            .font(.regular12)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var isToday: Bool {
        return item.date.startOfDay() == Date.now.startOfDay()
    }
}

#if DEBUG

struct TodoItemDetailPreviews: PreviewProvider {
    static var previews: some View {
        let item = TodoItem(
            plannableID: "1",
            type: .assignment,
            title: "Important Assignment"
        )
        return TodoItemDetail(item: item, itemDueOnSameDateAsNext: false)
    }
}

#endif
