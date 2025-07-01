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

struct GradeListWidgetScreen: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: GradeListModel

    var body: some View {
        content
            .defaultWidgetContainer()
    }

    @ViewBuilder
    private var content: some View {
        if model.isLoggedIn {
            if model.items.isNotEmpty {
                GradeListView(model: model)
            } else {
                GradeListFailureView()
            }
        } else {
            GradeListLoggedOutView()
        }
    }
}

// MARK: - Previews

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
