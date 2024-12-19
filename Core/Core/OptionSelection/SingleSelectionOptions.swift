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

public struct SingleSelectionOptions {
    public let all: [OptionItem]
    public let selected: CurrentValueSubject<OptionItem?, Never>
    private let initial: OptionItem?

    public var hasChanges: Bool {
        selected.value != initial
    }

    // designated init
    public init(
        all: [OptionItem],
        selected: CurrentValueSubject<OptionItem?, Never>,
        initial: OptionItem?
    ) {
        self.all = all
        self.selected = selected
        self.initial = initial
    }

    /// Uses `initial` value to create the `selected` subject.
    public init(
        all: [OptionItem],
        initial: OptionItem?
    ) {
        self.init(all: all, selected: .init(initial), initial: initial)
    }

    /// Uses `selected` subject's current value as `initial` value.
    public init(
        all: [OptionItem],
        selected: CurrentValueSubject<OptionItem?, Never>
    ) {
        self.init(all: all, selected: selected, initial: selected.value)
    }

    public func resetSelection() {
        selected.value = initial
    }
}
