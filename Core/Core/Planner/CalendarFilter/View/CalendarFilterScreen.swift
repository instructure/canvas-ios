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
            VStack(spacing: 0) {
                if let filter = viewModel.userFilter {
                    InstUI.CheckboxCell(
                        name: filter.name,
                        isSelected: selectionBinding(context: filter.context),
                        color: filter.color
                    )
                }

                if !viewModel.courseFilters.isEmpty {
                    InstUI.ListSectionHeader(name: String(localized: "Courses"))

                    ForEach(viewModel.courseFilters) { filter in
                        InstUI.CheckboxCell(
                            name: filter.name,
                            isSelected: selectionBinding(context: filter.context),
                            color: filter.color
                        )
                    }
                }

                if !viewModel.groupFilters.isEmpty {
                    InstUI.ListSectionHeader(name: String(localized: "Groups"))

                    ForEach(viewModel.groupFilters) { filter in
                        InstUI.CheckboxCell(
                            name: filter.name,
                            isSelected: selectionBinding(context: filter.context),
                            color: filter.color
                        )
                    }
                }
            }
        }
        .navigationTitle(viewModel.pageTitle)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.didTapRightNavButton.send()
                } label: {
                    Text(viewModel.rightNavButtonTitle)
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    viewModel.didTapDoneButton.send(viewController.value)
                } label: {
                    Text("Done", bundle: .core)
                }
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
}

#if DEBUG

#Preview {
    PlannerAssembly.makeFilterScreenPreview()
}

#endif
