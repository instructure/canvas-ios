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

struct GradeWidget: Widget {
    static let kind: String = "GradeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: GradeWidgetProvider()) { model in
            GradeWidgetScreen(model: model.data)
        }
        .contentMarginsDisabled()
        .configurationDisplayName(String(localized: "Grade Widget", comment: "Name of the grade widget"))
        .description(String(localized: "View the grade of your course.", comment: "Description of the grade widget"))
        .supportedFamilies([.systemSmall])
    }
}

#if DEBUG

#Preview("GradeWidget", as: .systemSmall) {
    GradeWidget()
} timeline: {
    GradeWidgetEntry(data: GradeModel.make(), date: Date())
}

#endif
