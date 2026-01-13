//
// This file is part of Canvas.
// Copyright (C) 2024-present  Instructure, Inc.
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

struct DashboardWidgetLayout: View {
    let fullWidthWidgets: [any LearnerWidgetViewModel]
    let gridWidgets: [any LearnerWidgetViewModel]

    var body: some View {
        GeometryReader { geometry in
            let columnCount = columns(for: geometry.size.width)

            VStack(spacing: 0) {
                fullWidthSection()
                gridSection(columnCount: columnCount)
            }
            .frame(width: geometry.size.width, alignment: .top)
            .animation(.easeInOut(duration: 0.3), value: columnCount)
        }
    }

    @ViewBuilder
    private func fullWidthSection() -> some View {
        ForEach(fullWidthWidgets, id: \.id) { viewModel in
            LearnerDashboardWidgetAssembly.makeView(for: viewModel)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
    }

    @ViewBuilder
    private func gridSection(columnCount: Int) -> some View {
        if !gridWidgets.isEmpty {
            HStack(alignment: .top, spacing: 16) {
                ForEach(0..<columnCount, id: \.self) { columnIndex in
                    columnView(columnIndex: columnIndex, columnCount: columnCount)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }

    private func columnView(columnIndex: Int, columnCount: Int) -> some View {
        LazyVStack(spacing: 16) {
            ForEach(Array(gridWidgets.enumerated()), id: \.offset) { index, viewModel in
                if index % columnCount == columnIndex {
                    LearnerDashboardWidgetAssembly.makeView(for: viewModel)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func columns(for width: CGFloat) -> Int {
        switch width {
        case ..<600: 1
        case 600..<840: 2
        default: 3
        }
    }
}

#if DEBUG

#Preview("Mixed: Full Width + Grid") {
    ScrollView {
        DashboardWidgetLayout(
            fullWidthWidgets: [
                LearnerDashboardWidgetAssembly.makeWidgetViewModel(
                    config: WidgetConfig(id: .fullWidthWidget, order: 0, isVisible: true, settings: nil)
                )
            ],
            gridWidgets: [
                LearnerDashboardWidgetAssembly.makeWidgetViewModel(
                    config: WidgetConfig(id: .widget1, order: 1, isVisible: true, settings: nil)
                ),
                LearnerDashboardWidgetAssembly.makeWidgetViewModel(
                    config: WidgetConfig(id: .widget2, order: 2, isVisible: true, settings: nil)
                ),
                LearnerDashboardWidgetAssembly.makeWidgetViewModel(
                    config: WidgetConfig(id: .widget3, order: 3, isVisible: true, settings: nil)
                )
            ]
        )
    }
}

#Preview("Only Grid Widgets") {
    ScrollView {
        DashboardWidgetLayout(
            fullWidthWidgets: [],
            gridWidgets: [
                LearnerDashboardWidgetAssembly.makeWidgetViewModel(
                    config: WidgetConfig(id: .widget1, order: 0, isVisible: true, settings: nil)
                ),
                LearnerDashboardWidgetAssembly.makeWidgetViewModel(
                    config: WidgetConfig(id: .widget2, order: 1, isVisible: true, settings: nil)
                ),
                LearnerDashboardWidgetAssembly.makeWidgetViewModel(
                    config: WidgetConfig(id: .widget3, order: 2, isVisible: true, settings: nil)
                )
            ]
        )
    }
}

#Preview("Only Full Width Widgets") {
    ScrollView {
        DashboardWidgetLayout(
            fullWidthWidgets: [
                LearnerDashboardWidgetAssembly.makeWidgetViewModel(
                    config: WidgetConfig(id: .fullWidthWidget, order: 0, isVisible: true, settings: nil)
                )
            ],
            gridWidgets: []
        )
    }
}

#Preview("Empty State") {
    ScrollView {
        DashboardWidgetLayout(
            fullWidthWidgets: [],
            gridWidgets: []
        )
    }
}

#endif
