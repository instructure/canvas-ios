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

struct SelectCalendarScreen: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.viewController) private var viewController
    @ObservedObject private var viewModel: SelectCalendarViewModel

    init(viewModel: SelectCalendarViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        InstUI.BaseScreen(state: viewModel.state, config: viewModel.screenConfig) { _ in
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(viewModel.sections) { section in
                    if !section.items.isEmpty {
                        Section {
                            ForEach(section.items) { item in
                                itemCell(with: item)
                            }
                        } header: {
                            InstUI.ListSectionHeader(title: section.title)
                        }
                    }
                }
            }
        }
        .navigationTitle(viewModel.pageTitle)
    }

    private func itemCell(with item: CDCalendarFilterEntry) -> some View {
        InstUI.RadioButtonCell(
            title: item.name,
            value: item,
            selectedValue: $viewModel.selectedCalendar,
            color: item.color
        )
    }
}

#if DEBUG

#Preview {
    PlannerAssembly.makeSelectCalendarScreenPreview()
}

#endif
