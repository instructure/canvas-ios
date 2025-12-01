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
            VStack(spacing: 0) {
                InstUI.TopDivider()
                MultiSelectionView(
                    title: String(localized: "Visible Items", bundle: .core),
                    allOptions: viewModel.visibilityOptionItems,
                    selectedOptions: viewModel.selectedVisibilityOptions
                )
                SingleSelectionView(
                    title: String(localized: "Show tasks from", bundle: .core, comment: "Show tasks from a selected date"),
                    allOptions: viewModel.dateRangeStartItems,
                    selectedOption: viewModel.selectedDateRangeStart
                )
                SingleSelectionView(
                    title: String(localized: "Show tasks until", bundle: .core, comment: "Show tasks until a selected date"),
                    allOptions: viewModel.dateRangeEndItems,
                    selectedOption: viewModel.selectedDateRangeEnd
                )
            }
        }
        .navigationBarTitle(Text("To-do List Preferences", bundle: .core), displayMode: .inline)
        .navigationBarItems(
            leading: cancelButton,
            trailing: doneButton
        )
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
}

#if DEBUG

#Preview {
    NavigationView {
        TodoFilterScreen(viewModel: .make())
    }
}

#endif
