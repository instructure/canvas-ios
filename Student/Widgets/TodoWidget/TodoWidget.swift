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

struct TodoWidget: Widget {
    static let kind: String = "TodoWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: TodoWidgetProvider()) { model in
            let _ = print("update todo widget ..")
            TodoWidgetScreen(model: model.data)
        }
        .configurationDisplayName(String(localized: "Todo", comment: "Name of the todo widget"))
        .contentMarginsDisabled()
        .description(String(localized: "View your todo items.", comment: "Description of the todo widget"))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#if DEBUG

#Preview("TodoWidget", as: .systemMedium) {
    TodoWidget()
} timeline: {
    TodoWidgetEntry(data: TodoModel.make(), date: Date())
}

#endif
