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

public final class AssignmentFilterViewModel: ObservableObject {

    struct FilterOptions {
        let gradingPeriod: GradingPeriod?
        let sortingOption: AssignmentArrangementOptions?
    }

    // MARK: - Outputs

    @Published private(set) var isSaveButtonEnabled = false
    @Published private(set) var isGradingPeriodsSectionVisible = false
    @Published private(set) var gradingPeriods: [GradingPeriod] = []
    @Published private(set) var sortingOptions: [AssignmentArrangementOptions] = []
    let courseName: String?

    @Published var selectedGradingPeriod: GradingPeriod? {
        didSet {
            updateSaveButton()
        }
    }

    @Published var selectedSortingOption: AssignmentArrangementOptions? {
        didSet {
            updateSaveButton()
        }
    }

    // MARK: - Private variables

    private let initialGradingPeriod: GradingPeriod?
    private let initialSortingOption: AssignmentArrangementOptions
    private let completion: (FilterOptions?) -> Void

    // MARK: - Init

    init(
        gradingPeriods: [GradingPeriod],
        initialGradingPeriod: GradingPeriod?,
        sortingOptions: [AssignmentArrangementOptions],
        initialSortingOption: AssignmentArrangementOptions,
        courseName: String?,
        completion: @escaping (FilterOptions?) -> Void
    ) {
        self.gradingPeriods = gradingPeriods
        self.selectedGradingPeriod = initialGradingPeriod
        self.initialGradingPeriod = initialGradingPeriod
        self.sortingOptions = sortingOptions
        self.selectedSortingOption = initialSortingOption
        self.initialSortingOption = initialSortingOption
        self.courseName = courseName
        self.completion = completion

        if gradingPeriods.count > 1 {
            isGradingPeriodsSectionVisible = true
        }
    }

    // MARK: - Functions

    func updateSaveButton() {
        isSaveButtonEnabled = selectedGradingPeriod != initialGradingPeriod || selectedSortingOption != initialSortingOption
    }

    func saveButtonTapped(viewController: WeakViewController) {
        completion(FilterOptions(gradingPeriod: selectedGradingPeriod, sortingOption: selectedSortingOption))
    }

    func dismiss(viewController: WeakViewController) {
        completion(nil)
    }
}
