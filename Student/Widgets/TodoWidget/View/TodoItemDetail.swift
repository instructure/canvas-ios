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
    var item: Plannable
    let itemDueOnSameDateAsNext: Bool
    var itemDate: Date { item.date ?? Date.distantFuture }
    var isToday: Bool { itemDate.dateOnlyString == Date.now.dateOnlyString }

    var body: some View {
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

    private var contextSection: some View {
        HStack(spacing: 4) {
            if let itemIcon = item.icon() {
                Image(uiImage: itemIcon)
                    .size(16)
                    .foregroundStyle(item.color.asColor)
                InstUI.Divider()
                    .frame(maxHeight: 16)
            }
            Text(item.contextName ?? "ASD")
                .foregroundStyle(item.color.asColor)
                .font(.regular12)
        }
    }

    private var titleSection: some View {
        Text(item.title ?? "ASD")
            .font(.semibold14)
            .foregroundStyle(Color.textDarkest)
    }

    private var timeSection: some View {
        Text(itemDate.formatted(.dateTime.hour().minute()))
            .font(.regular12)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG

struct TodoItemDetailPreviews: PreviewProvider {
    static var previews: some View {
        let apiPlannable = APIPlannable.make(
            plannable_type: "assignment",
            plannable: APIPlannable.plannable(
                details: "Description",
                title: "Important Assignment"
            )
        )
        let item = Plannable.save(apiPlannable, userID: "", in: PreviewEnvironment().database.viewContext)
        return TodoItemDetail(item: item, itemDueOnSameDateAsNext: false)
        .containerBackground(for: .widget) {
            SwiftUI.EmptyView()
        }
        .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}

#endif
