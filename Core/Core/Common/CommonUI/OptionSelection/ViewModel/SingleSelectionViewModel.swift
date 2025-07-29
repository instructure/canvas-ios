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

public final class SingleSelectionViewModel: ObservableObject {

    public let title: String?

    public let allOptions: [OptionItem]
    @Published public private(set) var selectedOption: OptionItem?
    public let selectedOptionSubject: CurrentValueSubject<OptionItem?, Never>
    public let didSelectOption: PassthroughSubject<OptionItem?, Never>?

    public let optionCount: Int
    public let listLevelAccessibilityLabel: String?

    private var subscriptions = Set<AnyCancellable>()

    public init(
        title: String?,
        allOptions: [OptionItem],
        selectedOption selectedOptionSubject: CurrentValueSubject<OptionItem?, Never>,
        didSelectOption: PassthroughSubject<OptionItem?, Never>? = nil
    ) {
        self.title = title

        self.allOptions = allOptions
        self.selectedOptionSubject = selectedOptionSubject
        self.didSelectOption = didSelectOption

        self.optionCount = allOptions.count
        if title != nil {
            // if there is a title -> list count is already in section header
            self.listLevelAccessibilityLabel = nil
        } else {
            // if there is no title -> add list count to first focused option
            self.listLevelAccessibilityLabel = String.localizedAccessibilityListCount(optionCount)
        }

        selectedOptionSubject
            .removeDuplicates()
            .assign(to: \.selectedOption, on: self, ownership: .weak)
            .store(in: &subscriptions)

        didSelectOption?
            .assign(to: \.selectedOption, on: self, ownership: .weak)
            .store(in: &subscriptions)
    }

    public func dividerStyle(for item: OptionItem) -> InstUI.Divider.Style {
        item.id == allOptions.last?.id ? .full : .padded
    }
}
