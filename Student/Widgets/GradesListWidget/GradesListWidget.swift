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

struct GradesListWidget: Widget {
    static let kind: String = "GradesListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: GradesListWidgetProvider()) { model in
            GradesListWidgetScreen(model: model.data)
        }
        .contentMarginsDisabled()
        .configurationDisplayName(String(localized: "Grades List", comment: "Name of the Grades List widget"))
        .description(String(localized: "View your grades.", comment: "Description of the Grades List widget"))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#if DEBUG

#Preview("GradesListWidget", as: .systemMedium) {
    GradesListWidget()
} timeline: {
    GradesListWidgetEntry(data: GradesListModel.make(), date: Date())
}

#Preview("GradesListWidget", as: .systemLarge) {
    GradesListWidget()
} timeline: {
    GradesListWidgetEntry(data: GradesListModel.make(), date: Date())
}

#endif
