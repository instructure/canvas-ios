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

    // MARK: Helper Types
    typealias ResultType = CourseSmartSearchResultType

    enum AllSelectionMode: Equatable {
        case deselect
        case select

        var title: LocalizedStringKey {
            switch self {
            case .deselect:
                return "Deselect all"
            case .select:
                return "Select all"
            }
        }
    }

    // MARK: Properties

    let sortModeOptions: [OptionItem]
    let selectedSortModeOption = CurrentValueSubject<OptionItem?, Never>(nil)

    let resultTypeOptions: [OptionItem]
    let selectedResultTypeOptions = CurrentValueSubject<Set<OptionItem>, Never>([])

    private var initialFilter: CourseSmartSearchFilter?
    private var selection: Binding<CourseSmartSearchFilter?>
    private var subscriptions = Set<AnyCancellable>()

    // MARK: Initialization

    init(selection: Binding<CourseSmartSearchFilter?>, accentColor: Color?) {
        self.selection = selection

        let initialFilter = selection.wrappedValue
        self.initialFilter = initialFilter

        sortModeOptions = CourseSmartSearchFilter.SortMode.allCases.map {
            $0.optionItem(color: accentColor)
        }
        let initialSortMode = initialFilter?.sortMode ?? .relevance
        let initialSortModeOption = initialSortMode.optionItem(color: accentColor)
        selectedSortModeOption.value = initialSortModeOption

        self.resultTypeOptions = ResultType.filterableTypes.map { $0.optionItem(color: accentColor) }
        let initialResultTypes = initialFilter?.includedTypes.nilIfEmpty ?? ResultType.filterableTypes
        let initialResultTypeOptions = Set(initialResultTypes.map { $0.optionItem(color: accentColor) })
        selectedResultTypeOptions.value = initialResultTypeOptions

        Publishers
            .CombineLatest(
                selectedSortModeOption,
                selectedResultTypeOptions
            )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (sortModeOption, resultTypeOptions) in
                self?.updateSelection(
                    sortMode: .init(optionItem: sortModeOption),
                    resultTypes: resultTypeOptions.compactMap { selected in
                        CourseSmartSearchResultType.filterableTypes.first { $0.isMatch(for: selected) }
                    }
                )
            }
            .store(in: &subscriptions)
    }

    // MARK: Exposed to View

    var allSelectionMode: AllSelectionMode {
        return isAllSelected ? .deselect : .select
    }

    func allSelectionButtonTapped() {
        if isAllSelected {
            selectedResultTypeOptions.value = []
        } else {
            selectedResultTypeOptions.value = Set(resultTypeOptions)
        }
    }

    func cancel() {
        selection.wrappedValue = initialFilter
    }

    // MARK: Privates

    private func updateSelection(
        sortMode: CourseSmartSearchFilter.SortMode?,
        resultTypes: [CourseSmartSearchResultType]
    ) {
        let allChecked = isAllSelected
        let allUnchecked = selectedResultTypeOptions.value.isEmpty

        if sortMode == .relevance, allChecked || allUnchecked {  // This is invalid case
            selection.wrappedValue = nil
            return
        }

        selection.wrappedValue = CourseSmartSearchFilter(
            sortMode: sortMode ?? .relevance,
            includedTypes: resultTypes
        )
    }

    private var isAllSelected: Bool {
        selectedResultTypeOptions.value == Set(resultTypeOptions)
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

    func optionItem(color: Color?) -> OptionItem {
        .init(id: rawValue, title: title, color: color)
    }
}

private extension CourseSmartSearchResultType {
    func optionItem(color: Color?) -> OptionItem {
        .init(id: rawValue, title: title, color: color, accessoryIcon: icon)
    }

    func isMatch(for optionItem: OptionItem?) -> Bool {
        rawValue == optionItem?.id
    }
}
