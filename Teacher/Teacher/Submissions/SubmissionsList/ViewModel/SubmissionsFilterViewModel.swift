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
    let sectionFilterOptions: MultiSelectionOptions?
    let differentiationTagFilterOptions: MultiSelectionOptions
    let sortModeOptions: SingleSelectionOptions

    let scoredMoreFilterValue: CurrentValueSubject<String, Never>
    let scoredLessFilterValue: CurrentValueSubject<String, Never>

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

        if sectionOptions.count > 1 {
            sectionFilterOptions = MultiSelectionOptions(
                all: sectionOptions,
                initial: sectionSelection
            )
        } else {
            sectionFilterOptions = nil
        }

        var differentiationTagOptions = listViewModel.differentiationTags.map {
            OptionItem(
                id: $0.id,
                title: $0.name,
                headerTitle: $0.isSingleTag ? nil : $0.parentGroupSet.name
            )
        }

        if differentiationTagOptions.isNotEmpty {
            differentiationTagOptions.insert(
                OptionItem(
                    id: GetSubmissions.Filter.DifferentiationTag.UsersWithoutTagsID,
                    title: String(localized: "Students without Differentiation tags", bundle: .teacher)
                ),
                at: 0
            )
        }

        let selectedDifferentiationTagOptions = differentiationTagOptions.filter {
            listViewModel.differentiationTagFilters.contains($0.id) || listViewModel.differentiationTagFilters.isEmpty
        }
        differentiationTagFilterOptions = MultiSelectionOptions(
            all: differentiationTagOptions,
            initial: Set(selectedDifferentiationTagOptions)
        )

        let sortOptionItems = SubmissionsSortMode.allCases.map { order in
            OptionItem(id: order.rawValue, title: order.name)
        }

        sortModeOptions = SingleSelectionOptions(
            all: sortOptionItems,
            initialId: listViewModel.sortMode.rawValue
        )

        let formatter = GradeFormatter.numberFormatter

        scoredMoreFilterValue = .init(listViewModel
            .scoreBasedFilters
            .moreThanFilter
            .flatMap({ formatter.string(from: NSNumber(value: $0.score)) }) ?? ""
        )

        scoredLessFilterValue = .init(
            listViewModel
                .scoreBasedFilters
                .lessThanFilter
                .flatMap({ formatter.string(from: NSNumber(value: $0.score)) }) ?? ""
        )
    }

    func saveSelection() {
        listViewModel.statusFilters = selectedStatusFilters
        listViewModel.sectionFilters = selectedSectionFilters
        listViewModel.scoreBasedFilters = selectedScoreBasedFilters
        listViewModel.differentiationTagFilters = selectedDifferentiationTagFilters
        listViewModel.sortMode = selectedSortMode
    }

    // MARK: Selection

    private var assignment: Assignment? {
        listViewModel.assignment
    }

    var isScoreBasedFilteringEnabled: Bool {
        assignment?.pointsPossible != nil
    }

    var pointsPossibleText: String {
        return assignment?.pointsPossibleText ?? ""
    }

    var pointsPossibleAccessibilityText: String {
        return assignment?.pointsPossibleCompleteText ?? ""
    }

    // MARK: Selection

    private var selectedStatusFilters: Set<SubmissionStatusFilter> {
        Set(
            statusFilterOptions.selected.value.compactMap({ SubmissionStatusFilter(rawValue: $0.id) })
        )
    }

    private var selectedSectionFilters: Set<String> {
        Set(sectionFilterOptions?.selected.value.map(\.id) ?? [])
    }

    private var selectedScoreBasedFilters: Set<GetSubmissions.Filter.Score> {
        var filters = Set<GetSubmissions.Filter.Score>()
        if let moreThanValue = scoredMoreFilterValue.value.doubleValueByFixingDecimalSeparator {
            filters.insert(.moreThan(moreThanValue))
        }
        if let lessThanValue = scoredLessFilterValue.value.doubleValueByFixingDecimalSeparator {
            filters.insert(.lessThan(lessThanValue))
        }
        return filters
    }

    private var selectedDifferentiationTagFilters: Set<String> {
        Set(differentiationTagFilterOptions.selected.value.map(\.id))
    }

    private var selectedSortMode: SubmissionsSortMode {
        sortModeOptions
            .selected
            .value
            .flatMap({ SubmissionsSortMode(rawValue: $0.id) })
        ?? .studentSortableName
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
