//
// This file is part of Canvas.
// Copyright (C) 2026-present  Instructure, Inc.
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

import Core
import Foundation
import Observation

@Observable
final class LearnItemFilterViewModel {
    // MARK: - Outputs

    private(set) var selectedSortOption: CollectionItemSortOption?
    private(set) var selectedFilterTypes: [LearnItemModel.UIItemType] = [.all]

    // MARK: - Dependencies

    private let router: Router
    private let onSetSortOption: (CollectionItemSortOption?, [LearnItemModel.UIItemType]?) -> Void

    // MARK: - Init

    init(
        router: Router,
        selectedSortOption: CollectionItemSortOption? = nil,
        selectedFilterTypes: [LearnItemModel.UIItemType]? = nil,
        onSetSortOption: @escaping (CollectionItemSortOption?, [LearnItemModel.UIItemType]?) -> Void
    ) {
        self.router = router
        self.selectedSortOption = selectedSortOption
        self.selectedFilterTypes = selectedFilterTypes ?? [.all]
        self.onSetSortOption = onSetSortOption
    }

    // MARK: - Input Actions

    func toggleSortOption(_ item: CollectionItemSortOption) {
        if selectedSortOption == item {
            selectedSortOption = nil
        } else {
            selectedSortOption = item
        }
    }

    func toggleFilterType(_ item: LearnItemModel.UIItemType) {
        if item == .all {
            selectedFilterTypes = [.all]
        } else {
            if selectedFilterTypes.contains(item) {
                selectedFilterTypes.removeAll { $0 == item }
                if selectedFilterTypes.isEmpty {
                    selectedFilterTypes = [.all]
                }
            } else {
                selectedFilterTypes.removeAll { $0 == .all }
                selectedFilterTypes.append(item)
            }
        }
    }

    func clearFilter(viewController: WeakViewController) {
        selectedSortOption = nil
        selectedFilterTypes = [.all]
        onSetSortOption(nil, nil)
        router.dismiss(viewController)
    }

    func dismiss(viewController: WeakViewController) {
        router.dismiss(viewController)
    }

    func apply(viewController: WeakViewController) {
        onSetSortOption(selectedSortOption, selectedFilterTypes == [.all] ? nil : selectedFilterTypes)
        router.dismiss(viewController)
    }
}
