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
    var gradingPeriodOptions: SingleSelectionOptions = .init(all: [], initial: nil)
    var sortModeOptions: SingleSelectionOptions = .init(all: [], initial: nil)

    // MARK: - Private Properties
    private let dependency: Dependency
    private let gradeFilterInteractor: GradeFilterInteractor
    private var sortModes: [GradeArrangementOptions] = []

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
    }

    private func mapGradingPeriod() {
        guard dependency.isShowGradingPeriod,
              let gradingPeriods = dependency.gradingPeriods,
              !gradingPeriods.isEmpty
        else {
            isShowGradingPeriodsView = false
            return
        }

        let initialGradingPeriod = gradingPeriods.first { $0.id == gradeFilterInteractor.selectedGradingId }
        gradingPeriodOptions = .init(
            all: [GradingPeriod.optionItemAll] + gradingPeriods.map { $0.optionItem },
            initial: initialGradingPeriod?.optionItem ?? GradingPeriod.optionItemAll
        )
    }

    private func mapSortByOptions() {
        sortModes = dependency.sortByOptions

        let initialSortMode = gradeFilterInteractor.selectedSortById.flatMap(GradeArrangementOptions.init)
            ?? .dueDate
        sortModeOptions = .init(
            all: sortModes.map { $0.optionItem },
            initial: initialSortMode.optionItem
        )
    }

    private func bindSaveButtonStates() {
        Publishers.CombineLatest(
            gradingPeriodOptions.selected,
            sortModeOptions.selected
        )
        .mapToVoid()
        .map { [gradingPeriodOptions, sortModeOptions] in
            [gradingPeriodOptions, sortModeOptions].contains { $0.hasChanges }
        }
        .assign(to: &$saveButtonIsEnabled)
    }

    func saveButtonTapped(viewController: WeakViewController) {
        let selectedSortingOption = GradeArrangementOptions(optionItem: sortModeOptions.selected.value)
            ?? .dueDate
        dependency.selectedSortByPublisher.accept(selectedSortingOption)
        gradeFilterInteractor.saveSortByOption(type: selectedSortingOption)

        let optionId = gradingPeriodOptions.selected.value?.id
        let selectedGradingPeriodId = optionId == OptionItem.allId ? nil : optionId
        dependency.selectedGradingPeriodPublisher.accept(selectedGradingPeriodId)
        gradeFilterInteractor.saveSelectedGradingPeriod(id: selectedGradingPeriodId)

        dependency.router.dismiss(viewController) {
            UIAccessibility.announce(String(localized: "Filter applied successfully", bundle: .core))
        }
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

private extension GradeArrangementOptions {
    private var title: String {
        switch self {
        case .dueDate:
            return String(localized: "Due Date", bundle: .core)
        case .groupName:
            return String(localized: "Group", bundle: .core)
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
        title: String(localized: "All Grading Periods", bundle: .core)
    )

    var optionItem: OptionItem {
        .init(id: id ?? "", title: title ?? "")
    }
}
