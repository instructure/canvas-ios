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

// MARK: - Structs

public struct AssignmentFilterOptionStudent: CaseIterable, Equatable, Identifiable {
    public static func == (lhs: AssignmentFilterOptionStudent, rhs: AssignmentFilterOptionStudent) -> Bool {
        lhs.id == rhs.id && lhs.title == rhs.title && lhs.subtitle == rhs.subtitle
    }

    public let id: String
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

    public static let allCases: [AssignmentFilterOptionStudent] = [
        .notYetSubmitted,
        .toBeGraded,
        .graded,
        .noSubmission
    ]
}

public enum AssignmentFilterOptionsTeacher: String, CaseIterable {
    case allAssignments
    case needsGrading
    case notSubmitted

    var rule: (Assignment) -> Bool {
        switch self {
        case .allAssignments: return { _ in true}
        case .needsGrading:
            return { $0.needsGradingCount > 0 }
        case .notSubmitted:
            return {
                if let submissions = $0.submissions {
                    guard submissions.count > 0 else { return true }
                    return !submissions.filter { $0.submittedAt == nil && ![SubmissionType.none, SubmissionType.on_paper].contains($0.type) }.isEmpty
                }
                return true
            }
        }
    }
}

public enum AssignmentStatusFilterOptionsTeacher: String, CaseIterable {
    case allAssignments
    case published
    case unpublished

    var rule: (Assignment) -> Bool {
        switch self {
        case .allAssignments: return { _ in true}
        case .published:
            return { $0.published }
        case .unpublished:
            return { !$0.published }
        }
    }
}

// MARK: - ViewModel

public final class AssignmentListPreferencesViewModel: ObservableObject {
    struct AssignmentListPreferences {
        let filterOptionsStudent: [AssignmentFilterOptionStudent]
        let filterOptionTeacher: AssignmentFilterOptionsTeacher?
        let statusFilterOptionTeacher: AssignmentStatusFilterOptionsTeacher?
        let sortingOption: AssignmentListViewModel.AssignmentArrangementOptions?
        let gradingPeriodId: String?
    }

    // MARK: - Outputs

    // Filter Options
    @Published private(set) var selectedAssignmentFilterOptionsStudent: [AssignmentFilterOptionStudent]
    let selectedFilterOptionTeacherItem = CurrentValueSubject<OptionItem?, Never>(nil)
    let selectedStatusFilterOptionTeacherItem = CurrentValueSubject<OptionItem?, Never>(nil)

    // Sorting Options
    let selectedSortingOptionItem = CurrentValueSubject<OptionItem?, Never>(nil)

    // Grading Periods
    let selectedGradingPeriodItem = CurrentValueSubject<OptionItem?, Never>(nil)

    // MARK: - Private properties

    private let initialFilterOptionsStudent: [AssignmentFilterOptionStudent]
    private let initialFilterOptionTeacherItem: OptionItem
    private let initialStatusFilterOptionTeacherItem: OptionItem
    private let initialSortingOptionItem: OptionItem
    private let initialGradingPeriodItem: OptionItem

    private let env: AppEnvironment
    private let completion: (AssignmentListPreferences) -> Void

    // MARK: - Other properties and literals

    let isTeacher: Bool
    private let sortingOptions: [AssignmentListViewModel.AssignmentArrangementOptions]
    let filterOptionTeacherItems: [OptionItem]
    let statusFilterOptionTeacherItems: [OptionItem]
    let sortingOptionItems: [OptionItem]
    let gradingPeriodItems: [OptionItem]

    let courseName: String
    let isGradingPeriodsSectionVisible: Bool

    // MARK: - Init

    init(
        isTeacher: Bool,
        initialFilterOptionsStudent: [AssignmentFilterOptionStudent],
        initialStatusFilterOptionTeacher: AssignmentStatusFilterOptionsTeacher,
        initialFilterOptionTeacher: AssignmentFilterOptionsTeacher,
        sortingOptions: [AssignmentListViewModel.AssignmentArrangementOptions],
        initialSortingOption: AssignmentListViewModel.AssignmentArrangementOptions,
        gradingPeriods: [GradingPeriod],
        initialGradingPeriod: GradingPeriod?,
        courseName: String,
        env: AppEnvironment,
        completion: @escaping (AssignmentListPreferences) -> Void
    ) {
        self.isTeacher = isTeacher

        // Filter Options
        self.selectedAssignmentFilterOptionsStudent = initialFilterOptionsStudent
        self.initialFilterOptionsStudent = initialFilterOptionsStudent

        self.statusFilterOptionTeacherItems = AssignmentStatusFilterOptionsTeacher.allCases.map { $0.optionItem }
        let initialStatusFilterOptionTeacherItem = initialStatusFilterOptionTeacher.optionItem
        self.initialStatusFilterOptionTeacherItem = initialStatusFilterOptionTeacherItem
        self.selectedStatusFilterOptionTeacherItem.value = initialStatusFilterOptionTeacherItem

        self.filterOptionTeacherItems = AssignmentFilterOptionsTeacher.allCases.map { $0.optionItem }
        let initialFilterOptionTeacherItem = initialFilterOptionTeacher.optionItem
        self.initialFilterOptionTeacherItem = initialFilterOptionTeacherItem
        self.selectedFilterOptionTeacherItem.value = initialFilterOptionTeacherItem

        // Sorting Options
        self.sortingOptions = sortingOptions
        self.sortingOptionItems = sortingOptions.map { $0.optionItem }
        let initialSortingOptionItem = initialSortingOption.optionItem
        self.initialSortingOptionItem = initialSortingOptionItem
        selectedSortingOptionItem.value = initialSortingOptionItem

        // Grading Periods
        self.gradingPeriodItems = [GradingPeriod.optionItemAll] + gradingPeriods.map { $0.optionItem }
        let initialGradingPeriodItem = initialGradingPeriod?.optionItem ?? GradingPeriod.optionItemAll
        self.initialGradingPeriodItem = initialGradingPeriodItem
        selectedGradingPeriodItem.value = initialGradingPeriodItem

        // Other
        self.courseName = courseName
        self.completion = completion

        self.env = env
        self.isGradingPeriodsSectionVisible = gradingPeriods.count > 1
    }

    // MARK: - Functions

    func didTapCancel(viewController: WeakViewController) {
        selectedAssignmentFilterOptionsStudent = initialFilterOptionsStudent
        selectedSortingOptionItem.value = initialSortingOptionItem
        selectedGradingPeriodItem.value = initialGradingPeriodItem
        selectedFilterOptionTeacherItem.value = initialFilterOptionTeacherItem
        selectedStatusFilterOptionTeacherItem.value = initialStatusFilterOptionTeacherItem
        env.router.dismiss(viewController)
    }

    func didTapDone(viewController: WeakViewController) {
        env.router.dismiss(viewController)
    }

    func didDismiss() {
        let optionId = selectedGradingPeriodItem.value?.id
        let gradingPeriodId = optionId == OptionItem.allId ? nil : optionId

        completion(
            AssignmentListPreferences(
                filterOptionsStudent: selectedAssignmentFilterOptionsStudent,
                filterOptionTeacher: .init(optionItem: selectedFilterOptionTeacherItem.value),
                statusFilterOptionTeacher: .init(optionItem: selectedStatusFilterOptionTeacherItem.value),
                sortingOption: sortingOptions.first { $0.isMatch(for: selectedSortingOptionItem.value) },
                gradingPeriodId: gradingPeriodId
            )
        )
    }

    func didSelectAssignmentFilterOption(_ option: AssignmentFilterOptionStudent, isSelected: Bool) {
        guard let indexOfOption = selectedAssignmentFilterOptionsStudent.firstIndex(of: option) else {
            if isSelected {
                selectedAssignmentFilterOptionsStudent.insert(option)
            }
            return
        }

        if !isSelected {
            selectedAssignmentFilterOptionsStudent.remove(at: indexOfOption)
        }
    }
}

private extension AssignmentListViewModel.AssignmentArrangementOptions {
    private var title: String {
        switch self {
        case .dueDate:
            return String(localized: "Due Date", bundle: .core)
        case .groupName:
            return String(localized: "Group", bundle: .core)
        case .assignmentGroup:
            return String(localized: "Assignment Group", bundle: .core)
        case .assignmentType:
            return String(localized: "Assignment Type", bundle: .core)
        }
    }

    var optionItem: OptionItem {
        .init(id: rawValue, title: title)
    }

    func isMatch(for optionItem: OptionItem?) -> Bool {
        rawValue == optionItem?.id
    }
}

private extension AssignmentFilterOptionsTeacher {
    private var title: String {
        switch self {
        case .allAssignments:
            String(localized: "All Assignments", bundle: .core)
        case .needsGrading:
            String(localized: "Needs Grading", bundle: .core)
        case .notSubmitted:
            String(localized: "Not Submitted", bundle: .core)
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

private extension AssignmentStatusFilterOptionsTeacher {
    private var title: String {
        switch self {
        case .allAssignments:
            return String(localized: "All Assignments", bundle: .core)
        case .published:
            return String(localized: "Published", bundle: .core)
        case .unpublished:
            return String(localized: "Unpublished", bundle: .core)
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
