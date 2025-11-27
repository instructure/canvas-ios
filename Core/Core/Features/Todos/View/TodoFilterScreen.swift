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

struct TodoFilterScreen: View {

    @Environment(\.viewController) private var viewController
    @StateObject private var viewModel: TodoFilterViewModel

    init(viewModel: TodoFilterViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                InstUI.TopDivider()
                visibilitySection
                InstUI.Divider()
                dateRangeStartSection
                InstUI.Divider()
                dateRangeEndSection
            }
        }
        .navigationBarTitle(Text("To-do List Preferences", bundle: .core), displayMode: .inline)
        .navigationBarItems(
            leading: cancelButton,
            trailing: doneButton
        )
    }

    private var visibilitySection: some View {
        Section {
            ForEach(viewModel.visibilityOptionItems) { item in
                InstUI.CheckboxCell(
                    title: item.title,
                    headerTitle: item.headerTitle,
                    subtitle: item.subtitle,
                    isSelected: visibilityBinding(for: item),
                    dividerStyle: dividerStyle(
                        for: item,
                        in: viewModel.visibilityOptionItems,
                        shouldHideLastDivider: true
                    )
                )
            }
        } header: {
            InstUI.ListSectionHeader(
                title: String(localized: "Visible Items", bundle: .core),
                itemCount: viewModel.visibilityOptionItems.count
            )
        }
    }

    private var dateRangeStartSection: some View {
        Section {
            ForEach(viewModel.dateRangeStartItems) { item in
                InstUI.RadioButtonCell(
                    title: item.title,
                    headerTitle: item.headerTitle,
                    subtitle: item.subtitle,
                    value: item,
                    selectedValue: $viewModel.selectedDateRangeStart,
                    dividerStyle: dividerStyle(
                        for: item,
                        in: viewModel.dateRangeStartItems,
                        shouldHideLastDivider: true
                    )
                )
            }
        } header: {
            InstUI.ListSectionHeader(
                title: String(localized: "Show tasks from", bundle: .core, comment: "Show tasks from a selected date"),
                itemCount: viewModel.dateRangeStartItems.count
            )
        }
    }

    private var dateRangeEndSection: some View {
        Section {
            ForEach(viewModel.dateRangeEndItems) { item in
                InstUI.RadioButtonCell(
                    title: item.title,
                    headerTitle: item.headerTitle,
                    subtitle: item.subtitle,
                    value: item,
                    selectedValue: $viewModel.selectedDateRangeEnd,
                    dividerStyle: dividerStyle(
                        for: item,
                        in: viewModel.dateRangeEndItems,
                        shouldHideLastDivider: false
                    )
                )
            }
        } header: {
            InstUI.ListSectionHeader(
                title: String(localized: "Show tasks until", bundle: .core, comment: "Show tasks until a selected date"),
                itemCount: viewModel.dateRangeEndItems.count
            )
        }
    }

    private var cancelButton: some View {
        Button {
            viewController.value.dismiss(animated: true)
        } label: {
            Text("Cancel", bundle: .core)
        }
    }

    private var doneButton: some View {
        Button {
            viewModel.applyFilters()
            viewController.value.dismiss(animated: true)
        } label: {
            Text("Done", bundle: .core)
        }
    }

    private func visibilityBinding(for item: OptionItem) -> Binding<Bool> {
        Binding {
            viewModel.selectedVisibilityOptions.contains(item)
        } set: { isSelected in
            if isSelected {
                viewModel.selectedVisibilityOptions.insert(item)
            } else {
                viewModel.selectedVisibilityOptions.remove(item)
            }
        }
    }

    private func dividerStyle(
        for item: OptionItem,
        in items: [OptionItem],
        shouldHideLastDivider: Bool
    ) -> InstUI.Divider.Style {
        let isLastItem = (item.id == items.last?.id)

        if isLastItem {
            return shouldHideLastDivider ? .hidden : .full
        } else {
            return .padded
        }
    }
}

#if DEBUG

#Preview {
    NavigationView {
        TodoFilterScreen(viewModel: .make())
    }
}

#endif
