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

import Core
import SwiftUI

struct DashboardWidgetLayout: View {
    let fullWidthWidgets: [any DashboardWidgetViewModel]
    let gridWidgets: [any DashboardWidgetViewModel]
    @State private var containerWidth: CGFloat = 0

    var body: some View {
        VStack(spacing: InstUI.Styles.Padding.standard.rawValue) {
            fullWidthSection()
            gridSection(columnCount: LearnerDashboardWidgetLayoutHelpers.columns(for: containerWidth))
        }
        .animation(.smooth, value: fullWidthWidgets.map { $0.layoutIdentifier })
        .animation(.smooth, value: gridWidgets.map { $0.layoutIdentifier })
        .onWidthChange { width in
            // Don't animate the first appearance
            withAnimation(containerWidth == 0 ? .none : .smooth) {
                containerWidth = width
            }
        }
    }

    @ViewBuilder
    private func fullWidthSection() -> some View {
        ForEach(fullWidthWidgets, id: \.id) { viewModel in
            LearnerDashboardWidgetAssembly.makeView(for: viewModel)
        }
    }

    @ViewBuilder
    private func gridSection(columnCount: Int) -> some View {
        if !gridWidgets.isEmpty {
            HStack(alignment: .top, spacing: InstUI.Styles.Padding.standard.rawValue) {
                ForEach(0..<columnCount, id: \.self) { columnIndex in
                    columnView(columnIndex: columnIndex, columnCount: columnCount)
                }
            }
        }
    }

    private func columnView(columnIndex: Int, columnCount: Int) -> some View {
        LazyVStack(spacing: InstUI.Styles.Padding.standard.rawValue) {
            ForEach(Array(gridWidgets.enumerated()), id: \.offset) { index, viewModel in
                if index % columnCount == columnIndex {
                    LearnerDashboardWidgetAssembly.makeView(for: viewModel)
                }
            }
        }
    }
}

#if DEBUG

#Preview {
    let snackBarViewModel = SnackBarViewModel()
    let courseInvitations = LearnerDashboardWidgetAssembly.makeWidgetViewModel(
        config: DashboardWidgetConfig(id: .courseInvitations, order: 0, isVisible: true, settings: nil),
        snackBarViewModel: snackBarViewModel
    )
    let widget1 = LearnerDashboardWidgetAssembly.makeWidgetViewModel(
        config: DashboardWidgetConfig(id: .widget1, order: 1, isVisible: true, settings: nil),
        snackBarViewModel: snackBarViewModel
    )
    let widget2 = LearnerDashboardWidgetAssembly.makeWidgetViewModel(
        config: DashboardWidgetConfig(id: .widget2, order: 2, isVisible: true, settings: nil),
        snackBarViewModel: snackBarViewModel
    )
    let widget3 = LearnerDashboardWidgetAssembly.makeWidgetViewModel(
        config: DashboardWidgetConfig(id: .widget3, order: 3, isVisible: true, settings: nil),
        snackBarViewModel: snackBarViewModel
    )

    _ = courseInvitations.refresh(ignoreCache: false)
    _ = widget1.refresh(ignoreCache: false)
    _ = widget2.refresh(ignoreCache: false)
    _ = widget3.refresh(ignoreCache: false)

    return ScrollView {
        DashboardWidgetLayout(
            fullWidthWidgets: [courseInvitations],
            gridWidgets: [widget1, widget2, widget3]
        )
        .paddingStyle(.horizontal, .standard)
    }
}

#endif
