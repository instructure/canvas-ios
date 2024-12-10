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
    var gradingPeriodItems: [OptionItem] = []
    let selectedGradingPeriodItem = CurrentValueSubject<OptionItem?, Never>(nil)
    var sortingOptionItems: [OptionItem] = []
    let selectedSortingOptionItem = CurrentValueSubject<OptionItem?, Never>(nil)

    // MARK: - Private Properties
    private let dependency: Dependency
    private let gradeFilterInteractor: GradeFilterInteractor
    private var initialFilterValue = FilterValue()
    private var sortingOptions: [GradeArrangementOptions] = []

    // MARK: - Init
    init(
        dependency: Dependency,
        gradeFilterInteractor: GradeFilterInteractor
    ) {
        self.dependency = dependency
        self.gradeFilterInteractor = gradeFilterInteractor
        setupOutputBindings()
        bindSaveButtonStates()
    }

    // MARK: - Functions
    private func setupOutputBindings() {
        courseName = dependency.courseName
        mapGradingPeriod()
        mapSortByOptions()
        initialFilterValue = FilterValue(
            gradingPeriodItem: selectedGradingPeriodItem.value,
            sortingOptionItem: selectedSortingOptionItem.value
        )
    }

    private func mapGradingPeriod() {
        guard dependency.isShowGradingPeriod,
              let gradingPeriods = dependency.gradingPeriods,
              !gradingPeriods.isEmpty
        else {
            isShowGradingPeriodsView = false
            return
        }

        gradingPeriodItems = [GradingPeriod.optionItemAll] + gradingPeriods.map { $0.optionItem }
        let initialGradingPeriod = gradingPeriods.first { $0.id == gradeFilterInteractor.selectedGradingId }
        selectedGradingPeriodItem.value = initialGradingPeriod?.optionItem ?? GradingPeriod.optionItemAll
    }

    private func mapSortByOptions() {
        sortingOptions = dependency.sortByOptions
        sortingOptionItems = sortingOptions.map { $0.optionItem }

        let selectedSortingOption = gradeFilterInteractor.selectedSortById.flatMap(GradeArrangementOptions.init)
            ?? .dueDate

        selectedSortingOptionItem.value = selectedSortingOption.optionItem
    }

    private func bindSaveButtonStates() {
        Publishers.CombineLatest(
            selectedGradingPeriodItem,
            selectedSortingOptionItem
        )
        .map { [initialFilterValue] gradingPeriodItem, sortingOptionItem in
            let selectedFilterValue = FilterValue(
                gradingPeriodItem: gradingPeriodItem,
                sortingOptionItem: sortingOptionItem
            )
            return initialFilterValue != selectedFilterValue
        }
        .assign(to: &$saveButtonIsEnabled)
    }

    func saveButtonTapped(viewController: WeakViewController) {
        let selectedSortingOption = GradeArrangementOptions(optionItem: selectedSortingOptionItem.value)
            ?? .dueDate
        dependency.selectedSortByPublisher.accept(selectedSortingOption)
        gradeFilterInteractor.saveSortByOption(type: selectedSortingOption)

        let optionId = selectedGradingPeriodItem.value?.id
        let selectedGradingPeriodId = optionId == OptionItem.allId ? nil : optionId
        dependency.selectedGradingPeriodPublisher.accept(selectedGradingPeriodId)
        gradeFilterInteractor.saveSelectedGradingPeriod(id: selectedGradingPeriodId)

        dimiss(viewController: viewController)
    }

    func dimiss(viewController: WeakViewController) {
        dependency.router.dismiss(viewController)
    }
}

// MARK: - Dependency
extension GradeFilterViewModel {
    public struct Dependency {
        let router: Router
        let isShowGradingPeriod: Bool
        var courseName: String?
        var selectedGradingPeriodPublisher = PassthroughRelay<String?>()
        var selectedSortByPublisher = CurrentValueRelay<GradeArrangementOptions>(.dueDate)
        var gradingPeriods: [GradingPeriod]?
        var sortByOptions: [GradeArrangementOptions]
    }
}

// MARK: - Helpers
extension GradeFilterViewModel {
    /// Using this type to match between the initial values and the changed values to
    /// make the save button is enabled or disabled
    fileprivate struct FilterValue: Equatable {
        var gradingPeriodItem: OptionItem?
        var sortingOptionItem: OptionItem?
    }
}

private extension GradeArrangementOptions {
    private var title: String {
        switch self {
        case .groupName:
            return String(localized: "Group", bundle: .core)
        case .dueDate:
            return String(localized: "Due Date", bundle: .core)
        }
    }

    var optionItem: OptionItem {
        .init(id: rawValue, title: title)
    }

    init?(optionItem: OptionItem?) {
        guard let optionItem else { return nil }

        self.init(rawValue: optionItem.id)
    }
}

private extension GradingPeriod {
    static let optionItemAll = OptionItem(
        id: OptionItem.allId,
        title: String(localized: "All", bundle: .core)
    )

    var optionItem: OptionItem {
        .init(id: id ?? "", title: title ?? "")
    }
}
