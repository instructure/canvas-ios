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

import Combine

final class MultiSelectionViewModel: ObservableObject {

    let options: [OptionItem]
    let selectedOptions: CurrentValueSubject<Set<OptionItem>, Never>

    let didToggleSelection = PassthroughSubject<(option: OptionItem, isSelected: Bool), Never>()

    private var subscriptions = Set<AnyCancellable>()

    init(
        options: [OptionItem],
        selectedOptions: CurrentValueSubject<Set<OptionItem>, Never>
    ) {
        self.options = options
        self.selectedOptions = selectedOptions

        selectedOptions
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &subscriptions)

        didToggleSelection
            .sink { [selectedOptions] (option, isSelected) in
                if isSelected {
                    selectedOptions.value.insert(option)
                } else {
                    selectedOptions.value.remove(option)
                }
            }
            .store(in: &subscriptions)
    }

    func isOptionSelected(_ option: OptionItem) -> Bool {
        selectedOptions.value.contains(option)
    }

    func dividerStyle(for item: OptionItem) -> InstUI.Divider.Style {
        item.id == options.last?.id ? .full : .padded
    }
}
