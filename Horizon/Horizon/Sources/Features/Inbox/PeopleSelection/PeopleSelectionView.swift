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

struct PeopleSelectionView: View {

    var disabled: Bool
    let placeholder: String
    @Bindable var viewModel: PeopleSelectionViewModel

    init(
        viewModel: PeopleSelectionViewModel,
        placeholder: String,
        disabled: Bool = false
    ) {
        self.viewModel = viewModel
        self.placeholder = placeholder
        self.disabled = disabled
    }

    var body: some View {
        HorizonUI.MultiSelect(
            selections: $viewModel.searchByPersonSelections,
            focused: $viewModel.isFocused,
            label: nil,
            textInput: $viewModel.searchString,
            options: viewModel.personOptions,
            loading: $viewModel.searchLoading,
            disabled: disabled,
            placeholder: placeholder
        )
    }
}
