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
import Combine

public class TodoFilterViewModel: ObservableObject {

    // MARK: - Outputs

    @Published public private(set) var visibilityOptionItems: [OptionItem] = []
    @Published public private(set) var dateRangeStartItems: [OptionItem] = []
    @Published public private(set) var dateRangeEndItems: [OptionItem] = []

    // MARK: - Inputs

    @Published public var selectedVisibilityOptions: Set<OptionItem> = []
    @Published public var selectedDateRangeStart: OptionItem?
    @Published public var selectedDateRangeEnd: OptionItem?

    // MARK: - Private Properties

    private var sessionDefaults: SessionDefaults

    public init(sessionDefaults: SessionDefaults) {
        self.sessionDefaults = sessionDefaults

        let savedFilters = sessionDefaults.todoFilterOptions ?? TodoFilterOptions.default

        self.visibilityOptionItems = TodoVisibilityOption.allOptionItems
        self.dateRangeStartItems = TodoDateRangeStart.allOptionItems()
        self.dateRangeEndItems = TodoDateRangeEnd.allOptionItems()

        self.selectedVisibilityOptions = Set(savedFilters.visibilityOptions.map { $0.toOptionItem() })
        self.selectedDateRangeStart = savedFilters.dateRangeStart.toOptionItem()
        self.selectedDateRangeEnd = savedFilters.dateRangeEnd.toOptionItem()
    }

    public func applyFilters() {
        let visibilityEnums = Set(selectedVisibilityOptions.compactMap { TodoVisibilityOption.from(optionItem: $0) })
        guard
            let selectedStart = selectedDateRangeStart,
            let selectedEnd = selectedDateRangeEnd,
            let startEnum = TodoDateRangeStart.from(optionItem: selectedStart),
            let endEnum = TodoDateRangeEnd.from(optionItem: selectedEnd)
        else {
            return
        }

        let newFilters = TodoFilterOptions(
            visibilityOptions: visibilityEnums,
            dateRangeStart: startEnum,
            dateRangeEnd: endEnum
        )

        sessionDefaults.todoFilterOptions = newFilters
    }
}

#if DEBUG

extension TodoFilterViewModel {
    public static func make(sessionDefaults: SessionDefaults = .fallback) -> TodoFilterViewModel {
        TodoFilterViewModel(sessionDefaults: sessionDefaults)
    }
}

#endif
