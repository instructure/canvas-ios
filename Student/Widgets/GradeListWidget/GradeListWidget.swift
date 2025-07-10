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

struct GradeListWidget: Widget {
    static let kind: String = "GradeListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: GradeListWidgetProvider()) { model in
            GradeListWidgetScreen(model: model.data)
        }
        .contentMarginsDisabled()
        .configurationDisplayName(Text("Grade List", comment: "Name of the Grade List widget"))
        .description(Text("View the grades of your favourite courses.", comment: "Description of the Grade List widget"))
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

#if DEBUG

#Preview("Medium", as: .systemMedium) {
    GradeListWidget()
} timeline: {
    GradeListWidgetEntry(data: GradeListModel.make(), date: Date())
}

#Preview("Large", as: .systemLarge) {
    GradeListWidget()
} timeline: {
    GradeListWidgetEntry(data: GradeListModel.make(), date: Date())
}

#endif
