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

public final class AssignmentFilterViewModel: ObservableObject {

    // MARK: - Outputs
    @Published private(set) var saveButtonIsEnabled = false
    @Published private(set) var isShowGradingPeriodsView = false
    @Published private(set) var courseName: String?
    @Published private(set) var gradingPeriods: [GradingPeriod] = []
    @Published private(set) var sortingOptions: [AssignmentArrangementOptions] = []
    @Published var selectedGradingPeriod: GradingPeriod? {
        didSet {
            checkChanges()
        }
    }
    @Published var selectedSortingOption: AssignmentArrangementOptions? {
        didSet {
            checkChanges()
        }
    }
    private var currentGradingPeriod: GradingPeriod?
    private var currentSortingOption: AssignmentArrangementOptions
    private let completion: (GradingPeriod?, AssignmentArrangementOptions?) -> Void

    // MARK: - Init
    init(
        gradingPeriods: [GradingPeriod],
        currentGradingPeriod: GradingPeriod?,
        sortingOptions: [AssignmentArrangementOptions],
        currentSortingOption: AssignmentArrangementOptions,
        completion: @escaping (GradingPeriod?, AssignmentArrangementOptions?) -> Void
    ) {
        self.gradingPeriods = gradingPeriods
        self.selectedGradingPeriod = currentGradingPeriod
        self.currentGradingPeriod = currentGradingPeriod
        self.sortingOptions = sortingOptions
        self.selectedSortingOption = currentSortingOption
        self.currentSortingOption = currentSortingOption
        self.completion = completion

        if gradingPeriods.count > 1 { isShowGradingPeriodsView = true }
    }

    // MARK: - Functions

    func checkChanges() {
        saveButtonIsEnabled = selectedGradingPeriod != currentGradingPeriod || selectedSortingOption != currentSortingOption
    }

    func saveButtonTapped(viewController: WeakViewController) {
        completion(selectedGradingPeriod, selectedSortingOption)
    }

    func dimiss(viewController: WeakViewController) {
        completion(nil, selectedSortingOption)
    }
}

// MARK: - Dependency
extension AssignmentFilterViewModel {

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
