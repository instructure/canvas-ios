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

// MARK: - Structs

public struct AssignmentFilterOption: CaseIterable, Equatable {
    public static func == (lhs: AssignmentFilterOption, rhs: AssignmentFilterOption) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
    }

    let id: String
    let title: String
    let subtitle: String?
    var submissionRule: (Submission) -> Bool

    private init(id: String, title: String, subtitle: String? = nil, submissionRule: @escaping (Submission) -> Bool) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.submissionRule = submissionRule
    }

    static let notYetSubmitted = Self(
        id: "notYetSubmitted",
        title: "Not Yet Submitted",
        subtitle: "Missing, Not Submitted",
        submissionRule: { submission in
            submission.missing && submission.submittedAt == nil
        }
    )

    static let toBeGraded = Self(
        id: "toBeGraded",
        title: "To Be Graded",
        subtitle: "Late, Submitted",
        submissionRule: { submission in
            submission.late && submission.submittedAt != nil
        }
    )

    static let graded = Self(
        id: "graded",
        title: "Graded",
        submissionRule: { submission in
            submission.gradedAt != nil
        }
    )

    public static let allCases: [AssignmentFilterOption] = [
        .notYetSubmitted,
        .toBeGraded,
        .graded
    ]
}

// MARK: - ViewModel

public final class AssignmentListPreferencesViewModel: ObservableObject {
    struct AssignmentListPreferences {
        let filterOptions: [AssignmentFilterOption]
        let gradingPeriod: GradingPeriod?
        let sortingOption: AssignmentArrangementOptions
        let courseId: String
    }

    // MARK: - Outputs

    @Published private(set) var isGradingPeriodsSectionVisible = false
    @Published private(set) var gradingPeriods: [GradingPeriod] = []
    @Published var selectedGradingPeriod: GradingPeriod?

    @Published private(set) var sortingOptions: [AssignmentArrangementOptions] = []
    @Published var selectedSortingOption: AssignmentArrangementOptions?

    @Published private(set) var selectedAssignmentFilterOptions: [AssignmentFilterOption]

    @Published private(set) var isStudentApp: Bool

    // MARK: - Private variables

    private let initialGradingPeriod: GradingPeriod?
    private let initialSortingOption: AssignmentArrangementOptions
    private let initialFilterOptions: [AssignmentFilterOption]?

    private let completion: (AssignmentListPreferences) -> Void

    // MARK: - Variables

    let courseId: String
    let courseName: String?
    let env: AppEnvironment

    // MARK: - Init

    init(
        gradingPeriods: [GradingPeriod],
        initialGradingPeriod: GradingPeriod?,
        sortingOptions: [AssignmentArrangementOptions],
        initialSortingOption: AssignmentArrangementOptions,
        initialFilterOptions: [AssignmentFilterOption] = AssignmentFilterOption.allCases,
        courseId: String,
        courseName: String?,
        env: AppEnvironment,
        completion: @escaping (AssignmentListPreferences) -> Void
    ) {
        self.gradingPeriods = gradingPeriods
        self.selectedGradingPeriod = initialGradingPeriod
        self.initialGradingPeriod = initialGradingPeriod
        self.sortingOptions = sortingOptions
        self.selectedSortingOption = initialSortingOption
        self.initialSortingOption = initialSortingOption
        self.selectedAssignmentFilterOptions = initialFilterOptions
        self.initialFilterOptions = initialFilterOptions
        self.courseId = courseId
        self.courseName = courseName
        self.env = env
        self.completion = completion

        if gradingPeriods.count > 1 {
            isGradingPeriodsSectionVisible = true
        }

        self.isStudentApp = env.app == .student
    }

    // MARK: - Functions

    func doneButtonTapped(viewController: WeakViewController) {
        dismiss(viewController: viewController)
        completion(
            AssignmentListPreferences(
                filterOptions: selectedAssignmentFilterOptions,
                gradingPeriod: selectedGradingPeriod,
                sortingOption: selectedSortingOption ?? AssignmentArrangementOptions.dueDate,
                courseId: courseId
            )
        )
    }

    func dismiss(viewController: WeakViewController) {
        AppEnvironment.shared.router.dismiss(viewController)
    }

    func didSelectAssignmentFilterOption(option: AssignmentFilterOption, isSelected: Bool) {
        if selectedAssignmentFilterOptions.contains(option) {
            if !isSelected {
                selectedAssignmentFilterOptions.remove(at: selectedAssignmentFilterOptions.firstIndex(of: option)!)
            }
        } else if isSelected {
            selectedAssignmentFilterOptions.insert(option)
        }
    }
}
