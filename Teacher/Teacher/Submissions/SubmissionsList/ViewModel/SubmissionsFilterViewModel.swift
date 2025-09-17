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

import Core
import SwiftUI
import Combine
import CombineSchedulers

struct SubmissionsFilterViewModel {

    let listViewModel: SubmissionListViewModel

    let courseColor: Color
    let assignmentName: String?

    let statusFilterOptions: MultiSelectionOptions
    let sectionFilterOptions: MultiSelectionOptions

    init(listViewModel: SubmissionListViewModel) {
        self.listViewModel = listViewModel

        courseColor = listViewModel.course.flatMap { Color(uiColor: $0.color) } ?? Color(Brand.shared.primary)
        assignmentName = listViewModel.assignment?.name

        let statusesSelection = Set(listViewModel.statusFilters.map({ OptionItem(id: $0.rawValue, title: $0.name) }))
        let allOptions = listViewModel.statusFilterOptions.map({ OptionItem(id: $0.rawValue, title: $0.name) })

        statusFilterOptions = MultiSelectionOptions(
            all: allOptions,
            initial: statusesSelection
        )

        let sectionSelection = Set(listViewModel.sectionFiltersRealized.map({ OptionItem(id: $0.id, title: $0.name) }))
        let sectionOptions = listViewModel.courseSections.map { OptionItem(id: $0.id, title: $0.name) }

        sectionFilterOptions = MultiSelectionOptions(
            all: sectionOptions,
            initial: sectionSelection
        )
    }

    func saveSelection() {
        listViewModel.statusFilters = selectedStatusFilters
        listViewModel.sectionFilters = selectedSectionFilters
    }

    // MARK: Selection

    private var selectedStatusFilters: Set<SubmissionStatusFilter> {
        Set(
            statusFilterOptions.selected.value.compactMap({ SubmissionStatusFilter(rawValue: $0.id) })
        )
    }

    private var selectedSectionFilters: Set<String> {
        Set(sectionFilterOptions.selected.value.map(\.id))
    }
}

// MARK: - Helpers

private extension SubmissionListViewModel {

    var statusFilterOptions: [SubmissionStatusFilter] {
        SubmissionStatusFilter.allCasesForCourse(interactor.context.id)
    }

    var sectionFiltersRealized: [CourseSection] {
        courseSections.filter { section in
            sectionFilters.contains(section.id)
        }
    }
}
