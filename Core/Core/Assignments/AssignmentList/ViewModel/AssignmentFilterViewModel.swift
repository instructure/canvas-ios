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

import Foundation
import Combine
import CombineExt

public final class AssignmentFilterViewModel: ObservableObject {

    // MARK: - Outputs
    @Published private(set) var saveButtonIsEnabled = false
    @Published private(set) var isShowingGradingPeriodView = true
    @Published private(set) var courseName: String?
    @Published private(set) var gradingPeriods: [GradePeriod] = []
    @Published private(set) var sortByOptions: [AssignmentArrangementOptions] = []
    @Published var selectedGradingPeriod: GradePeriod?
    @Published var selectedSortByOption: AssignmentArrangementOptions?

    // MARK: - Private Properties
    private let dependency: Dependency
    private let assignmentFilterInteractor: AssignmentFilterInteractor
    private var initialFilterValue = FilterValue()

    // MARK: - Init
    init(
        dependency: Dependency,
        assignmentFilterInteractor: AssignmentFilterInteractor
    ) {
        self.dependency = dependency
        self.assignmentFilterInteractor = assignmentFilterInteractor
        setupOutputBindings()
        bindSaveButtonStates()
    }

    // MARK: - Functions
    private func setupOutputBindings() {
        courseName = dependency.courseName
        mapGradingPeriod()
        mapSortByOptions()
        initialFilterValue = FilterValue(
            selectedGradingPeriod: selectedGradingPeriod,
            selectedSortBy: selectedSortByOption
        )
    }

    private func mapGradingPeriod() {
        guard dependency.isShowGradingPeriod,
              let gradingPeriodList = dependency.gradingPeriods,
              !gradingPeriodList.isEmpty else {
            isShowingGradingPeriodView = false
            return
        }

        // Selected Grading Period
        let defaultGradingPeriod = AssignmentFilterViewModel.GradePeriod(title: String(localized: "All", bundle: .core))
        let selectedGradingId = assignmentFilterInteractor.selectedGradingId
        let selectedGrading = gradingPeriodList.first(where: {$0.id ==  selectedGradingId})
        let currentGradingPeriod = AssignmentFilterViewModel.GradePeriod(
            title: selectedGrading?.title,
            value: selectedGrading
        )
        selectedGradingPeriod = selectedGrading == nil ? defaultGradingPeriod : currentGradingPeriod

        gradingPeriods.append(defaultGradingPeriod)
        let gradePeriods: [AssignmentFilterViewModel.GradePeriod] = gradingPeriodList.map { .init(title: $0.title, value: $0) }
        gradingPeriods.append(contentsOf: gradePeriods)
    }

    private func mapSortByOptions() {
        let selectedSortById = assignmentFilterInteractor.selectedSortById
        selectedSortByOption = AssignmentArrangementOptions(rawValue: selectedSortById ?? 0) ?? .dueDate
        sortByOptions = dependency.sortByOptions
    }

    private func bindSaveButtonStates() {
        Publishers.CombineLatest(
            $selectedGradingPeriod,
            $selectedSortByOption
        )
        .map { [initialFilterValue] grading, sortBy in
            let selectedFilterValue = FilterValue(
                selectedGradingPeriod: grading,
                selectedSortBy: sortBy
            )
            return initialFilterValue != selectedFilterValue
        }
        .assign(to: &$saveButtonIsEnabled)
    }

    func saveButtonTapped(viewController: WeakViewController) {
        dependency.selectedGradingPeriodPublisher.accept(selectedGradingPeriod?.value?.id)
        dependency.selectedSortByPublisher.accept(selectedSortByOption ?? .dueDate)
        let selectedGradingPeriodId = selectedGradingPeriod?.value?.id
        assignmentFilterInteractor.saveSelectedGradingPeriod(id: selectedGradingPeriodId)
        assignmentFilterInteractor.saveSortByOption(type: selectedSortByOption ?? .dueDate)
        dimiss(viewController: viewController)
    }

    func dimiss(viewController: WeakViewController) {
        dependency.router.dismiss(viewController)
    }
}

// MARK: - Dependency
extension AssignmentFilterViewModel {
    public struct Dependency {
        let router: Router
        let isShowGradingPeriod: Bool
        var courseName: String?
        var selectedGradingPeriodPublisher = PassthroughRelay<String?>()
        var selectedSortByPublisher = CurrentValueRelay<AssignmentArrangementOptions>(.dueDate)
        var gradingPeriods: [GradingPeriod]?
        var sortByOptions: [AssignmentArrangementOptions]
    }

    struct GradePeriod: Equatable, Hashable {
        let title: String?
        var value: GradingPeriod?
    }
}

// MARK: - Helpers
extension AssignmentFilterViewModel {
    /// Using this type to match between the initial values and the changed values to
    /// make the save button is enabled or disabled
    fileprivate struct FilterValue: Equatable {
        var selectedGradingPeriod: GradePeriod?
        var selectedSortBy: AssignmentArrangementOptions?
    }
}
