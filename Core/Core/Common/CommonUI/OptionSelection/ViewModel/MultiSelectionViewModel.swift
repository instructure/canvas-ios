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
import UIKit

final class MultiSelectionViewModel: ObservableObject {

    let allOptions: [OptionItem]
    let selectedOptions: CurrentValueSubject<Set<OptionItem>, Never>
    var allSelectionButtonTitle: String = ""

    let didToggleSelection = PassthroughSubject<(option: OptionItem, isSelected: Bool), Never>()
    let didTapAllSelectionButton = PassthroughSubject<Void, Never>()

    private var subscriptions = Set<AnyCancellable>()

    init(
        allOptions: [OptionItem],
        selectedOptions: CurrentValueSubject<Set<OptionItem>, Never>
    ) {
        self.allOptions = allOptions
        self.selectedOptions = selectedOptions

        selectedOptions
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.updateAllSelectionButton()
                self?.objectWillChange.send()
            }
            .store(in: &subscriptions)

        didToggleSelection
            .sink { (option, isSelected) in
                if isSelected {
                    selectedOptions.value.insert(option)
                } else {
                    selectedOptions.value.remove(option)
                }
            }
            .store(in: &subscriptions)

        didTapAllSelectionButton
            .sink { [weak self] in
                guard let self else { return }
                if isAllSelected {
                    deselectAll()
                } else {
                    selectAll()
                }
            }
            .store(in: &subscriptions)
    }

    private func selectAll() {
        selectedOptions.value = Set(allOptions)
        UIAccessibility.announce(String(localized: "All options selected", bundle: .core))
    }

    private func deselectAll() {
        selectedOptions.value = []
        UIAccessibility.announce(String(localized: "All options deselected", bundle: .core))
    }

    func isOptionSelected(_ option: OptionItem) -> Bool {
        selectedOptions.value.contains(option)
    }

    func dividerStyle(for item: OptionItem) -> InstUI.Divider.Style {
        item.id == allOptions.last?.id ? .full : .padded
    }

    private var isAllSelected: Bool {
        selectedOptions.value == Set(allOptions)
    }

    private func updateAllSelectionButton() {
        allSelectionButtonTitle = isAllSelected
            ? String(localized: "Deselect all", bundle: .core)
            : String(localized: "Select all", bundle: .core)
    }
}
