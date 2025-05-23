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

final class SingleSelectionViewModel: ObservableObject {

    let title: String?

    let allOptions: [OptionItem]
    let selectedOption: CurrentValueSubject<OptionItem?, Never>

    let optionCount: Int
    let listLevelAccessibilityLabel: String?

    private var subscriptions = Set<AnyCancellable>()

    init(
        title: String?,
        allOptions: [OptionItem],
        selectedOption: CurrentValueSubject<OptionItem?, Never>
    ) {
        self.title = title

        self.allOptions = allOptions
        self.selectedOption = selectedOption

        self.optionCount = allOptions.count
        if title != nil {
            // if there is a title -> list count is already in section header
            self.listLevelAccessibilityLabel = nil
        } else {
            // if there is no title -> add list count to first focused option
            self.listLevelAccessibilityLabel = String.localizedNumberOfItems(optionCount)
        }

        selectedOption
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &subscriptions)
    }

    func dividerStyle(for item: OptionItem) -> InstUI.Divider.Style {
        item.id == allOptions.last?.id ? .full : .padded
    }
}
