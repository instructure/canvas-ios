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

public struct CalendarFilterScreen: View, ScreenViewTrackable {
    public var screenViewTrackingParameters: ScreenViewTrackingParameters { viewModel.pageViewEvent }

    @ObservedObject private var viewModel: CalendarFilterViewModel
    @Environment(\.viewController) private var viewController

    public init(viewModel: CalendarFilterViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        InstUI.BaseScreen(
            state: viewModel.state,
            refreshAction: viewModel.refresh
        ) { _ in
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                filterCountInfo
                userFilter
                courseFilters
                groupFilters
            }
        }
        .navigationTitle(viewModel.pageTitle)
        .toolbar {
            doneButton
            selectAllButton
        }
        .snackBar(viewModel: viewModel.snackbarViewModel)
        // Without this the refreshable scroll view won't trigger the refresh
        // because the pull gesture is swallowed by the modal dialog dimiss gesture.
        // Even if the dismiss itself is disabled the bounce effect will swallow the event.
        // As a side effect we will see double loading indicators.
        .refreshable {}
    }

    private var selectAllButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            if let title = viewModel.selectAllButtonTitle {
                Button {
                    viewModel.didTapSelectAllButton.send()
                } label: {
                    Text(title)
                }
            } else {
                SwiftUI.EmptyView()
            }
        }
    }

    private var doneButton: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                viewModel.didTapDoneButton.send(viewController.value)
            } label: {
                Text("Done", bundle: .core)
            }
        }
    }

    private func selectionBinding(context: Context) -> Binding<Bool> {
        Binding {
            viewModel.selectedContexts.contains(context)
        } set: { newValue in
            viewModel.didToggleSelection.send((context, isSelected: newValue))
        }
    }

    @ViewBuilder
    private var filterCountInfo: some View {
        if let message = viewModel.filterLimitMessage {
            Text(message)
                .foregroundStyle(Color.textDarkest)
                .font(.regular16, lineHeight: .fit)
                .frame(maxWidth: .infinity, alignment: .leading)
                .paddingStyle(.horizontal, .standard)
                .padding(.top, 24)
                .padding(.bottom, 8)
        }
    }

    @ViewBuilder
    private var userFilter: some View {
        if let filter = viewModel.userFilter {
            InstUI.CheckboxCell(
                title: filter.name,
                isSelected: selectionBinding(context: filter.context),
                color: filter.color
            )
        }
    }

    @ViewBuilder
    private var courseFilters: some View {
        if !viewModel.courseFilters.isEmpty {
            Section {
                ForEach(viewModel.courseFilters) { filter in
                    InstUI.CheckboxCell(
                        title: filter.name,
                        isSelected: selectionBinding(context: filter.context),
                        color: filter.color
                    )
                }
            } header: {
                InstUI.ListSectionHeader(title: String(localized: "Courses", bundle: .core))
            }
        }
    }

    @ViewBuilder
    private var groupFilters: some View {
        if !viewModel.groupFilters.isEmpty {
            Section {
                ForEach(viewModel.groupFilters) { filter in
                    InstUI.CheckboxCell(
                        title: filter.name,
                        isSelected: selectionBinding(context: filter.context),
                        color: filter.color
                    )
                }
            } header: {
                InstUI.ListSectionHeader(title: String(localized: "Groups", bundle: .core))
            }
        }
    }
}

#if DEBUG

#Preview {
    PlannerAssembly.makeFilterScreenPreview()
}

#endif
