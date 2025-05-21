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
import Core
import WidgetKit

struct TodoItemDate: View {
    var item: Plannable
    let itemDueOnSameDateAsPrevious: Bool
    var itemDate: Date { item.date ?? Date.distantFuture }
    var isToday: Bool { itemDate.dateOnlyString == Date.now.dateOnlyString }

    var body: some View {
        VStack(spacing: 2) {
            if !itemDueOnSameDateAsPrevious {
                Text(itemDate.formatted(.dateTime.weekday()))
                    .font(.regular12)
                    .foregroundStyle(isToday ? .pink : .textDark)
                ZStack {
                    if isToday {
                        Circle()
                            .fill(.background)
                            .stroke(.pink, style: .init(lineWidth: 1))
                            .frame(width: 32, height: 32)
                    }
                    Text(itemDate.formatted(.dateTime.day()))
                        .font(.bold12)
                        .foregroundStyle(isToday ? .pink : .textDark)
                }
            }
        }
        .frame(minWidth: 34)
    }
}

#if DEBUG

struct TodoItemDatePreviews: PreviewProvider {
    static var previews: some View {
        let apiPlannable = APIPlannable.make(
            plannable_type: "assignment",
            plannable: APIPlannable.plannable(
                details: "Description",
                title: "Important Assignment"
            )
        )
        let item = Plannable.save(apiPlannable, userID: "", in: PreviewEnvironment().database.viewContext)
        return TodoItemDate(item: item, itemDueOnSameDateAsPrevious: false)
        .containerBackground(for: .widget) {
            SwiftUI.EmptyView()
        }
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

#endif
