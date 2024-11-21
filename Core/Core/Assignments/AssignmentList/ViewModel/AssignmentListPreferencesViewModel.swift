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

public struct GradingPeriodOption: Identifiable, Equatable {
    static let allGradingPeriods = Self(id: nil, title: String(localized: "All Grading Periods", bundle: .core))

    public let id: String?
    public let title: String?
}

public struct AssignmentFilterOption: CaseIterable, Equatable {
    public static func == (lhs: AssignmentFilterOption, rhs: AssignmentFilterOption) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
    }

    let id: String
    let title: String
    let subtitle: String?
    let rule: (Assignment) -> Bool

    private init(
        id: String,
        title: String,
        subtitle: String? = nil,
        rule: @escaping (Assignment) -> Bool
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.rule = rule
    }

    static let notYetSubmitted = Self(
        id: "notYetSubmitted",
        title: String(localized: "Not Yet Submitted", bundle: .core),
        rule: { assignment in
            if assignment.submissionTypes.contains(SubmissionType.none) || assignment.submissionTypes.contains(SubmissionType.on_paper) {
                return false
            }
            if let submission = assignment.submission {
                return (submission.missing || submission.submittedAt == nil) && !submission.isGraded
            }
            return false
        }
    )

    static let toBeGraded = Self(
        id: "toBeGraded",
        title: String(localized: "To Be Graded", bundle: .core),
        rule: { assignment in
            if assignment.submissionTypes.contains(.not_graded) {
                return false
            }
            if let submission = assignment.submission {
                return (submission.late || submission.submittedAt != nil) && submission.excused != true && !submission.isGraded
            }
            return false
        }
    )

    static let graded = Self(
        id: "graded",
        title: String(localized: "Graded", bundle: .core),
        rule: { assignment in
            if let submission = assignment.submission {
                return submission.isGraded
            }
            return false
        }
    )

    static let noSubmission = Self(
        id: "noSubmission",
        title: String(localized: "Other", bundle: .core),
        rule: { assignment in
            return assignment.submissionTypes.contains(SubmissionType.none)
                || assignment.submissionTypes.contains(SubmissionType.on_paper)
                || assignment.submission?.excused == true
        }
    )

    public static let allCases: [AssignmentFilterOption] = [
        .notYetSubmitted,
        .toBeGraded,
        .graded,
        .noSubmission
    ]
}

// MARK: - ViewModel

public final class AssignmentListPreferencesViewModel: ObservableObject {
    struct AssignmentListPreferences {
        let filterOptions: [AssignmentFilterOption]
        let sortingOption: AssignmentListViewModel.AssignmentArrangementOptions
        let gradingPeriodId: String?
    }

    // MARK: - Outputs

    // Filter Options
    @Published private(set) var selectedAssignmentFilterOptions: [AssignmentFilterOption]

    // Sorting Options
    @Published var selectedSortingOption: AssignmentListViewModel.AssignmentArrangementOptions?

    // Grading Periods
    @Published var selectedGradingPeriod: GradingPeriodOption?

    // MARK: - Private properties

    private let initialFilterOptions: [AssignmentFilterOption]
    private let initialSortingOption: AssignmentListViewModel.AssignmentArrangementOptions
    private let initialGradingPeriod: GradingPeriodOption?

    private let env: AppEnvironment
    private let completion: (AssignmentListPreferences) -> Void

    // MARK: - Other properties and literals

    let sortingOptions: [AssignmentListViewModel.AssignmentArrangementOptions]
    let gradingPeriods: [GradingPeriodOption]

    let courseName: String
    let isFilterSectionVisible: Bool
    let isGradingPeriodsSectionVisible: Bool

    // MARK: - Init

    init(
        initialFilterOptions: [AssignmentFilterOption] = AssignmentFilterOption.allCases,
        sortingOptions: [AssignmentListViewModel.AssignmentArrangementOptions],
        initialSortingOption: AssignmentListViewModel.AssignmentArrangementOptions,
        gradingPeriods: [GradingPeriod],
        initialGradingPeriod: GradingPeriod?,
        courseName: String,
        env: AppEnvironment,
        completion: @escaping (AssignmentListPreferences) -> Void
    ) {
        // Filter Options
        self.selectedAssignmentFilterOptions = initialFilterOptions
        self.initialFilterOptions = initialFilterOptions

        // Sorting Options
        self.sortingOptions = sortingOptions
        self.selectedSortingOption = initialSortingOption
        self.initialSortingOption = initialSortingOption

        // Grading Periods
        self.gradingPeriods = [GradingPeriodOption.allGradingPeriods] + gradingPeriods.map { GradingPeriodOption(id: $0.id ?? "", title: $0.title ?? "") }

        var initialGradingPeriodOption: GradingPeriodOption
        if let initialGradingPeriod {
            initialGradingPeriodOption = GradingPeriodOption(
                id: initialGradingPeriod.id ?? "",
                title: initialGradingPeriod.title ?? ""
            )
        } else {
            initialGradingPeriodOption = GradingPeriodOption.allGradingPeriods
        }
        self.selectedGradingPeriod = initialGradingPeriodOption
        self.initialGradingPeriod = initialGradingPeriodOption

        // Other
        self.courseName = courseName
        self.completion = completion

        self.env = env
        self.isGradingPeriodsSectionVisible = gradingPeriods.count > 1
        self.isFilterSectionVisible = self.env.app == .student
    }

    // MARK: - Functions

    func didTapCancel(viewController: WeakViewController) {
        selectedAssignmentFilterOptions = initialFilterOptions
        selectedSortingOption = initialSortingOption
        selectedGradingPeriod = initialGradingPeriod
        env.router.dismiss(viewController)
    }

    func didTapDone(viewController: WeakViewController) {
        env.router.dismiss(viewController)
    }

    func didDismiss() {
        completion(
            AssignmentListPreferences(
                filterOptions: selectedAssignmentFilterOptions,
                sortingOption: selectedSortingOption ?? AssignmentListViewModel.AssignmentArrangementOptions.dueDate,
                gradingPeriodId: selectedGradingPeriod?.id
            )
        )
    }

    func didSelectAssignmentFilterOption(_ option: AssignmentFilterOption, isSelected: Bool) {
        guard let indexOfOption = selectedAssignmentFilterOptions.firstIndex(of: option) else {
            if isSelected {
                selectedAssignmentFilterOptions.insert(option)
            }
            return
        }

        if !isSelected {
            selectedAssignmentFilterOptions.remove(at: indexOfOption)
        }
    }
}
