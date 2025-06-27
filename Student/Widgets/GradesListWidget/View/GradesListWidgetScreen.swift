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

struct GradesListWidgetScreen: View {

    @Environment(\.widgetFamily) private var family
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let model: GradesListModel

    var body: some View {
        content
            .defaultWidgetContainer()
    }

    @ViewBuilder
    private var content: some View {
        if model.isLoggedIn {
            if let items = model.getItems(for: family) {
                GradesListView(items: items)
            } else {
                GradesListFailureView()
            }
        } else {
            GradesListLoggedOutView()
        }
    }
}

// MARK: - Previews

#if DEBUG

#Preview("Medium", as: .systemMedium) {
    GradesListWidget()
} timeline: {
    GradesListWidgetEntry(data: GradesListModel.make(), date: Date())
}

#Preview("Large", as: .systemLarge) {
    GradesListWidget()
} timeline: {
    GradesListWidgetEntry(data: GradesListModel.make(), date: Date())
}

#endif
