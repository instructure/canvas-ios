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

public struct AssignmentFilterOptionStudent: CaseIterable, Equatable {
    public static func == (lhs: AssignmentFilterOptionStudent, rhs: AssignmentFilterOptionStudent) -> Bool {
        lhs.id == rhs.id
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

    // Student Filter
    let studentFilterOptions: MultiSelectionOptions

    // Teacher Filter
    let teacherFilterOptions: SingleSelectionOptions

    // Teacher Publish Status Filter
    let teacherPublishStatusFilterOptions: SingleSelectionOptions

    // Sort Mode
    let sortModeOptions: SingleSelectionOptions
    private let sortModes: [AssignmentListViewModel.AssignmentArrangementOptions]

    // Grading Periods
    let gradingPeriodOptions: SingleSelectionOptions

    // misc
    let isTeacher: Bool
    let courseName: String
    let isGradingPeriodsSectionVisible: Bool

    // MARK: - Private properties

    private let env: AppEnvironment
    private let completion: (AssignmentListPreferences) -> Void

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

        // Student Filter
        self.studentFilterOptions = .init(
            all: AssignmentFilterOptionStudent.allCases.map { $0.optionItem },
            initial: Set(initialFilterOptionsStudent.map { $0.optionItem })
        )

        // Teacher Filter
        self.teacherFilterOptions = .init(
            all: AssignmentFilterOptionsTeacher.allCases.map { $0.optionItem },
            initial: initialFilterOptionTeacher.optionItem
        )

        // Teacher Publish Status Filter
        self.teacherPublishStatusFilterOptions = .init(
            all: AssignmentStatusFilterOptionsTeacher.allCases.map { $0.optionItem },
            initial: initialStatusFilterOptionTeacher.optionItem
        )

        // Sorting Options
        self.sortModes = sortingOptions
        self.sortModeOptions = .init(
            all: sortingOptions.map { $0.optionItem },
            initial: initialSortingOption.optionItem
        )

        // Grading Periods
        self.gradingPeriodOptions = .init(
            all: [GradingPeriod.optionItemAll] + gradingPeriods.map { $0.optionItem },
            initial: initialGradingPeriod?.optionItem ?? GradingPeriod.optionItemAll
        )

        // Other
        self.courseName = courseName
        self.completion = completion

        self.env = env
        self.isGradingPeriodsSectionVisible = gradingPeriods.count > 1
    }

    // MARK: - Functions

    func didTapCancel(viewController: WeakViewController) {
        studentFilterOptions.resetSelection()
        teacherFilterOptions.resetSelection()
        teacherPublishStatusFilterOptions.resetSelection()
        sortModeOptions.resetSelection()
        gradingPeriodOptions.resetSelection()
        env.router.dismiss(viewController)
    }

    func didTapDone(viewController: WeakViewController) {
        env.router.dismiss(viewController)
    }

    func didDismiss() {
        let optionId = gradingPeriodOptions.selected.value?.id
        let gradingPeriodId = optionId == OptionItem.allId ? nil : optionId

        completion(
            AssignmentListPreferences(
                filterOptionsStudent: studentFilterOptions.selected.value.compactMap { selected in
                    AssignmentFilterOptionStudent.allCases.first { $0.isMatch(for: selected) }
                },
                filterOptionTeacher: .init(optionItem: teacherFilterOptions.selected.value),
                statusFilterOptionTeacher: .init(optionItem: teacherPublishStatusFilterOptions.selected.value),
                sortingOption: sortModes.first { $0.isMatch(for: sortModeOptions.selected.value) },
                gradingPeriodId: gradingPeriodId
            )
        )
    }
}

private extension AssignmentFilterOptionStudent {
    var optionItem: OptionItem {
        .init(id: id, title: title)
    }

    func isMatch(for optionItem: OptionItem?) -> Bool {
        id == optionItem?.id
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

private extension GradingPeriod {
    static let optionItemAll = OptionItem(
        id: OptionItem.allId,
        title: String(localized: "All Grading Periods", bundle: .core)
    )

    var optionItem: OptionItem {
        .init(id: id ?? "", title: title ?? "")
    }
}
