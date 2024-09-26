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

public final class GradeFilterViewModel: ObservableObject {

    // MARK: - Outputs
    @Published private(set) var saveButtonIsEnabled = false
    @Published private(set) var isShowGradingPeriodsView = true
    @Published private(set) var courseName: String?
    @Published private(set) var gradingPeriods: [GradePeriod] = []
    @Published private(set) var sortByOptions: [GradeArrangementOptions] = []
    @Published var selectedGradingPeriod: GradePeriod?
    @Published var selectedSortByOption: GradeArrangementOptions?

    // MARK: - Private Properties
    private let dependency: Dependency
    private let appEnvironment: AppEnvironment
    private var initialFilterValue = FilterValue()

    // MARK: - Init
    init(
        dependency: Dependency,
        appEnvironment: AppEnvironment
    ) {
        self.dependency = dependency
        self.appEnvironment = appEnvironment
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
            isShowGradingPeriodsView = false
            return
        }

        // Selected Grading Period
        let defaultGradingPeriod = GradeFilterViewModel.GradePeriod(title: String(localized: "All", bundle: .core))
        let selectedGradingId = appEnvironment.userDefaults?.selectedGradingPeriodId
        let selectedGrading = gradingPeriodList.first(where: {$0.id ==  selectedGradingId})
        let currentGradingPeriod = GradeFilterViewModel.GradePeriod(
            title: selectedGrading?.title,
            value: selectedGrading
        )
        selectedGradingPeriod = selectedGrading == nil ? defaultGradingPeriod : currentGradingPeriod

        gradingPeriods.append(defaultGradingPeriod)
        let gradePeriods: [GradeFilterViewModel.GradePeriod] = gradingPeriodList.map { .init(title: $0.title, value: $0) }
        gradingPeriods.append(contentsOf: gradePeriods)
    }

    private func mapSortByOptions() {
        let selectedSortById = appEnvironment.userDefaults?.selectedSortByOptionId
        selectedSortByOption = GradeArrangementOptions(rawValue: selectedSortById ?? 0) ?? .groupName
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
        dependency.selectedGradingPeriodPublisher.accept(selectedGradingPeriod?.value)
        dependency.selectedSortByPublisher.accept(selectedSortByOption ?? .groupName)
        let selectedGradingPeriodId = selectedGradingPeriod?.value?.id
        // -1 is dummy id so can present `All` grading period
        appEnvironment.userDefaults?.selectedGradingPeriodId = selectedGradingPeriodId == nil ? "-1" : selectedGradingPeriodId
        appEnvironment.userDefaults?.selectedSortByOptionId = selectedSortByOption?.rawValue
        dimiss(viewController: viewController)
    }

    func dimiss(viewController: WeakViewController) {
        dependency.router.dismiss(viewController)
    }
}

// MARK: - Dependency
extension GradeFilterViewModel {
    public struct Dependency {
        var router: Router
        var isShowGradingPeriod: Bool
        var courseName: String?
        var selectedGradingPeriodPublisher = PassthroughRelay<GradingPeriod?>()
        var selectedSortByPublisher = CurrentValueRelay<GradeArrangementOptions>(.groupName)
        var gradingPeriods: [GradingPeriod]?
        var sortByOptions: [GradeArrangementOptions]
    }

    struct GradePeriod: Equatable, Hashable {
        let title: String?
        var value: GradingPeriod?
    }
}

// MARK: - Helpers
extension GradeFilterViewModel {
    /// Using this type to match between the initial values and the changed values to
    /// make the save button is enabled or disabled
    fileprivate struct FilterValue: Equatable {
        var selectedGradingPeriod: GradePeriod?
        var selectedSortBy: GradeArrangementOptions?
    }
}
