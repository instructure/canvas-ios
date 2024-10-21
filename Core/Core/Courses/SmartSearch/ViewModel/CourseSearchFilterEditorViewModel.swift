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

    struct ResultTypeSelection {
        let type: ResultType
        var checked: Bool = true
    }

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

    @Published var sortMode: CourseSmartSearchFilter.SortMode? = .relevance
    @Published var resultTypes: [ResultTypeSelection]

    private let onSubmit: (CourseSmartSearchFilter?) -> Void

    // MARK: Initialization

    init(filter: CourseSmartSearchFilter?, onSubmit: @escaping (CourseSmartSearchFilter?) -> Void) {
        self.onSubmit = onSubmit
        self.sortMode = filter?.sortMode ?? .relevance

        let included = filter?.includedTypes.nilIfEmpty ?? ResultType.filterableTypes
        self.resultTypes = ResultType.filterableTypes.map({ type in
            let checked = included.contains(type)
            return ResultTypeSelection(type: type, checked: checked)
        })
    }

    // MARK: Exposed to View

    func isLastResultType(_ result: ResultTypeSelection) -> Bool {
        return result.type == resultTypes.last?.type
    }

    var allSelectionMode: AllSelectionMode {
        return isAllSelected ? .deselect : .select
    }

    func allSelectionButtonTapped() {
        if isAllSelected {
            resultTypes.indices.forEach { index in
                resultTypes[index].checked = false
            }
        } else {
            resultTypes.indices.forEach { index in
                resultTypes[index].checked = true
            }
        }
    }

    func submit() {
        onSubmit(selectedFilter)
    }

    // MARK: Privates

    private var selectedFilter: CourseSmartSearchFilter? {
        let allChecked = resultTypes.allSatisfy({ $0.checked })
        let allUnchecked = resultTypes.allSatisfy({ $0.checked == false })

        if (sortMode ?? .relevance) == .relevance,
            allChecked || allUnchecked { return nil } // This is invalid case

        return CourseSmartSearchFilter(
            sortMode: sortMode ?? .relevance,
            includedTypes: resultTypes
                .filter({ $0.checked })
                .map({ $0.type })
        )
    }

    private var isAllSelected: Bool {
        return resultTypes.allSatisfy({ $0.checked })
    }
}
