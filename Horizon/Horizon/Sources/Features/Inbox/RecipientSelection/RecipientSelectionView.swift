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

import HorizonUI
import SwiftUI

struct RecipientSelectionView: View {

    var disabled: Bool
    let placeholder: String
    @State private var searchLoading: Bool = false
    @Bindable var viewModel: RecipientSelectionViewModel

    init(
        viewModel: RecipientSelectionViewModel,
        placeholder: String,
        disabled: Bool = false
    ) {
        self.viewModel = viewModel
        self.placeholder = placeholder
        self.disabled = disabled
    }

    var body: some View {
        HorizonUI.MultiSelect(
            focused: Binding<Bool>(
                get: { viewModel.isFocusedSubject.value },
                set: onFocused
            ),
            selections: viewModel.searchByPersonSelections,
            label: nil,
            textInput: $viewModel.searchString,
            options: viewModel.personOptions,
            loading: $searchLoading,
            disabled: disabled,
            placeholder: placeholder
        ) { selections in
            viewModel.update(selections: selections)
        }
        .accessibilityLabel(viewModel.accessibilityDescription.isEmpty ? placeholder : viewModel.accessibilityDescription)
        .accessibilityAddTraits(.isButton)
        .accessibilityHint(String(format: String(localized: "Double tap to filter a recipients. %@"),
                                  viewModel.isFocusedSubject.value
                                  ? String(localized: "Expanded")
                                  : String(localized: "Collapsed"))
        )
    }

    private func onFocused(oldValue: Bool) {
        viewModel.isFocusedSubject.accept(oldValue)
        if !oldValue {
            dismissKeyboard()
        }
    }

    private func dismissKeyboard() {
        ScrollOffsetReader.dismissKeyboard()
    }
}
