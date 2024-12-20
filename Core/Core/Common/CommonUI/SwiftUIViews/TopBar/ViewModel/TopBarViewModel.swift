//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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
import SwiftUI

public class TopBarViewModel: ObservableObject {
    public let items: [TopBarItemViewModel]
    /** A Combine publisher for the `selectedItemIndex` property. The difference compared to the `@Published selectedItemIndex`variable is that **`selectedItemIndex`**
     signals **before** the new value is set and the viewModel state is updated while **selectedItemIndexPublisher** signals **after** the new value is set and the viewModel state is updated. */
    public var selectedItemIndexPublisher: AnyPublisher<Int, Never> { selectedItemIndexChanged.eraseToAnyPublisher() }
    @Published public var selectedItemIndex = 0 {
        didSet {
            updateSelectedItemState()
            selectedItemIndexChanged.send(selectedItemIndex)
        }
    }

    public var selectedItemId: String? {
        items[selectedItemIndex].id
    }

    private let selectedItemIndexChanged = CurrentValueSubject<Int, Never>(0)

    public init(items: [TopBarItemViewModel]) {
        self.items = items
        updateSelectedItemState()
    }

    public func itemInfo(for model: TopBarItemViewModel) -> (index: Int, isFirst: Bool, isLast: Bool)? {
        guard let index = items.firstIndex(of: model) else { return nil }

        let isFirst = (index == 0)
        let isLast = (index == items.count - 1)
        return (index: index, isFirst: isFirst, isLast: isLast)
    }

    private func updateSelectedItemState() {
        for (index, item) in items.enumerated() {
            item.isSelected = (index == selectedItemIndex)
        }
    }
}
