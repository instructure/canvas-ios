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
import SwiftUI

public class CourseSearchFilterEditorViewModel: ObservableObject {

    private typealias SortMode = CourseSmartSearchFilter.SortMode
    private typealias ResultType = CourseSmartSearchResultType

    // MARK: Properties

    let sortModeOptions: SingleSelectionOptions
    let resultTypeOptions: MultiSelectionOptions

    private var initialFilter: CourseSmartSearchFilter?
    private var selection: Binding<CourseSmartSearchFilter?>
    private var subscriptions = Set<AnyCancellable>()

    // MARK: Initialization

    init(selection: Binding<CourseSmartSearchFilter?>) {
        self.selection = selection

        let initialFilter = selection.wrappedValue
        self.initialFilter = initialFilter

        let initialSortMode = initialFilter?.sortMode ?? .relevance
        self.sortModeOptions = .init(
            all: SortMode.allCases.map { $0.optionItem },
            initial: initialSortMode.optionItem
        )

        let initialResultTypes = initialFilter?.includedTypes.nilIfEmpty ?? ResultType.filterableTypes
        self.resultTypeOptions = .init(
            all: ResultType.filterableTypes.map { $0.optionItem },
            initial: Set(initialResultTypes.map { $0.optionItem })
        )

        Publishers
            .CombineLatest(
                sortModeOptions.selected,
                resultTypeOptions.selected
            )
            .receive(on: DispatchQueue.main)
            .mapToVoid()
            .sink { [weak self] in
                self?.updateSelection()
            }
            .store(in: &subscriptions)
    }

    // MARK: Exposed to View

    func cancel() {
        selection.wrappedValue = initialFilter
    }

    // MARK: Privates

    private func updateSelection() {
        let sortMode = SortMode(optionItem: sortModeOptions.selected.value)
        let resultTypes = resultTypeOptions.selected.value.compactMap { selected in
            ResultType.filterableTypes.first { $0.isMatch(for: selected) }
        }

        let allChecked = resultTypeOptions.isAllSelected
        let allUnchecked = resultTypeOptions.isAllUnselected

        if sortMode == .relevance, allChecked || allUnchecked {  // This is invalid case
            selection.wrappedValue = nil
            return
        }

        selection.wrappedValue = CourseSmartSearchFilter(
            sortMode: sortMode ?? .relevance,
            includedTypes: resultTypes
        )
    }
}

private extension CourseSmartSearchFilter.SortMode {
    private var title: String {
        switch self {
        case .relevance:
            return String(localized: "Relevance", bundle: .core)
        case .type:
            return String(localized: "Type", bundle: .core)
        }
    }

    init?(optionItem: OptionItem?) {
        guard let optionItem else { return nil }

        self.init(rawValue: optionItem.id)
    }

    var optionItem: OptionItem {
        .init(id: rawValue, title: title)
    }
}

private extension CourseSmartSearchResultType {
    var optionItem: OptionItem {
        .init(id: rawValue, title: title, accessoryIcon: icon)
    }

    func isMatch(for optionItem: OptionItem?) -> Bool {
        rawValue == optionItem?.id
    }
}
