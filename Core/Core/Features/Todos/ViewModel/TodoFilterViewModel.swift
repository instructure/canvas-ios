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

class TodoFilterViewModel: ObservableObject {

    // MARK: - Outputs

    @Published private(set) var visibilityOptionItems: [OptionItem] = []
    @Published private(set) var dateRangeStartItems: [OptionItem] = []
    @Published private(set) var dateRangeEndItems: [OptionItem] = []

    // MARK: - Inputs

    @Published var selectedVisibilityOptions: Set<OptionItem> = []
    @Published var selectedDateRangeStart: OptionItem?
    @Published var selectedDateRangeEnd: OptionItem?

    // MARK: - Private Properties

    private var sessionDefaults: SessionDefaults
    private var onFiltersChanged: (() -> Void)?

    init(
        sessionDefaults: SessionDefaults,
        onFiltersChanged: (() -> Void)? = nil
    ) {
        self.sessionDefaults = sessionDefaults
        self.onFiltersChanged = onFiltersChanged

        let savedFilters = sessionDefaults.todoFilterOptions ?? TodoFilterOptions.default

        self.visibilityOptionItems = TodoVisibilityOption.allOptionItems
        self.dateRangeStartItems = TodoDateRangeStart.allOptionItems()
        self.dateRangeEndItems = TodoDateRangeEnd.allOptionItems()

        self.selectedVisibilityOptions = Set(savedFilters.visibilityOptions.map { $0.toOptionItem() })
        self.selectedDateRangeStart = savedFilters.dateRangeStart.toOptionItem()
        self.selectedDateRangeEnd = savedFilters.dateRangeEnd.toOptionItem()
    }

    func applyFilters() {
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

        let currentFilters = sessionDefaults.todoFilterOptions ?? TodoFilterOptions.default

        if newFilters != currentFilters {
            sessionDefaults.todoFilterOptions = newFilters
            onFiltersChanged?()
        }
    }
}

#if DEBUG

extension TodoFilterViewModel {
    public static func make(sessionDefaults: SessionDefaults = .fallback) -> TodoFilterViewModel {
        TodoFilterViewModel(sessionDefaults: sessionDefaults)
    }
}

#endif
