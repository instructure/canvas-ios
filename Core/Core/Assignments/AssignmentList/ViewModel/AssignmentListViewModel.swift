//
// This file is part of Canvas.
// Copyright (C) 2021-present  Instructure, Inc.
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

import SwiftUI

// MARK: - ViewModel

public class AssignmentListViewModel: ObservableObject {

    public enum AssignmentArrangementOptions: String, CaseIterable, Identifiable {
        static let studentCases: [Self] = [.dueDate, .groupName]
        static let teacherCases: [Self] = [.assignmentGroup, .assignmentType]

        case dueDate
        case groupName
        case assignmentGroup
        case assignmentType

        public var id: String { rawValue }

        var title: String {
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
    }

    public struct AssignmentDateGroup {
        public let id: String
        public let name: String
        public let assignments: [Assignment]
    }

    public enum ViewModelState<T: Equatable>: Equatable {
        case loading
        case empty
        case data(T)
    }

    // MARK: - Outputs

    @Published public private(set) var state: ViewModelState<[AssignmentGroupViewModel]> = .loading
    @Published public private(set) var courseColor: UIColor?
    @Published public private(set) var courseName: String?
    @Published public private(set) var defaultDetailViewRoute = "/empty"
    @Published public private(set) var isShowingGradingPeriods: Bool = false

    public var isFilterIconSolid: Bool = false
    public var defaultGradingPeriodId: String?
    public let defaultSortingOption: AssignmentArrangementOptions
    public var selectedGradingPeriodId: String?
    public var selectedGradingPeriodTitle: String? { gradingPeriods.filter({ $0.id == selectedGradingPeriodId }).first?.title }
    public var wasCurrentPeriodPreselected: Bool = false
    public var selectedSortingOption: AssignmentArrangementOptions

    // MARK: - Private properties

    private let isTeacher: Bool
    private let sortingOptions: [AssignmentArrangementOptions]
    private var initialFilterOptionsStudent: [AssignmentFilterOptionStudent] = AssignmentFilterOptionStudent.allCases
    private var selectedFilterOptionsStudent: [AssignmentFilterOptionStudent] = AssignmentFilterOptionStudent.allCases

    // Teacher
    private let filterOptionsTeacher: [AssignmentFilterOptionsTeacher] = AssignmentFilterOptionsTeacher.allCases
    private let statusFilterOptionsTeacher: [AssignmentStatusFilterOptionsTeacher] = AssignmentStatusFilterOptionsTeacher.allCases
    private var initialStatusFilterOptionTeacher: AssignmentStatusFilterOptionsTeacher = .allAssignments
    private var selectedStatusFilterOptionTeacher: AssignmentStatusFilterOptionsTeacher = .allAssignments
    private var initialFilterOptionTeacher: AssignmentFilterOptionsTeacher = .allAssignments
    private var selectedFilterOptionTeacher: AssignmentFilterOptionsTeacher = .allAssignments

    private var isFilteringCustom: Bool {
        if isTeacher {
            return !(selectedFilterOptionTeacher == initialFilterOptionTeacher && selectedStatusFilterOptionTeacher == initialStatusFilterOptionTeacher)
        } else {
            // all filters selected is the same as no filter selected
            return (!selectedFilterOptionsStudent.isEmpty) && selectedFilterOptionsStudent.count != AssignmentFilterOptionStudent.allCases.count
        }
    }

    private let env: AppEnvironment
    private var userDefaults: SessionDefaults?
    let courseID: String

    private lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.courseDidUpdate()
    }

    private lazy var gradingPeriods = env.subscribe(GetGradingPeriods(courseID: courseID)) { [weak self] in
        self?.gradingPeriodsDidUpdate()
    }

    private var assignmentGroups: Store<GetAssignmentsByGroup>?

    /** This is required for the router to help decide if the hybrid discussion details or the native one should be launched. */
    private lazy var featureFlags = env.subscribe(GetEnabledFeatureFlags(context: .course(courseID)))

    // MARK: - Init
    public init(
        env: AppEnvironment,
        context: Context,
        userDefaults: SessionDefaults? = nil,
        defaultGradingPeriod: GradingPeriod? = nil
    ) {
        self.env = env
        self.userDefaults = userDefaults ?? env.userDefaults
        self.isTeacher = env.app == .teacher
        self.sortingOptions = isTeacher ? AssignmentArrangementOptions.teacherCases : AssignmentArrangementOptions.studentCases
        self.defaultSortingOption = isTeacher ? .assignmentGroup : .dueDate
        self.selectedSortingOption = defaultSortingOption
        self.courseID = context.id

        loadAssignmentListPreferences()
        featureFlags.refresh()
    }

    // MARK: - Functions

    public func viewDidAppear() {
        gradingPeriods.refresh()
        course.refresh()
        isFilterIconSolid = isFilteringCustom || selectedGradingPeriodId != defaultGradingPeriodId
    }

    private func gradingPeriodsDidUpdate() {
        if !gradingPeriods.requested || gradingPeriods.pending { return }

        let currentGradingPeriod = gradingPeriods.filter {
            let rightNow = Clock.now
            if let start = $0.startDate, let end = $0.endDate {
                return start < rightNow && end > rightNow
            }
            return false
        }
        .first

        if !wasCurrentPeriodPreselected, let currentId = currentGradingPeriod?.id {
            defaultGradingPeriodId = currentId
            selectedGradingPeriodId = currentId
            wasCurrentPeriodPreselected = true
        }

        filterOptionsDidUpdate(filterOptionsStudent: selectedFilterOptionsStudent, gradingPeriodId: selectedGradingPeriodId)
        assignmentGroups?.refresh()
    }

    func filterOptionsDidUpdate(
        filterOptionsStudent: [AssignmentFilterOptionStudent]? = nil,
        filterOptionTeacher: AssignmentFilterOptionsTeacher? = nil,
        statusFilterOptionTeacher: AssignmentStatusFilterOptionsTeacher? = nil,
        sortingOption: AssignmentArrangementOptions? = nil,
        gradingPeriodId: String?
    ) {
        if gradingPeriodId == selectedGradingPeriodId
            && sortingOption == selectedSortingOption
            && filterOptionsStudent == selectedFilterOptionsStudent
            && filterOptionTeacher == selectedFilterOptionTeacher
            && statusFilterOptionTeacher == selectedStatusFilterOptionTeacher {
            return
        }

        selectedGradingPeriodId = gradingPeriodId
        selectedSortingOption = sortingOption ?? selectedSortingOption
        selectedFilterOptionsStudent = filterOptionsStudent ?? selectedFilterOptionsStudent
        selectedFilterOptionTeacher = filterOptionTeacher ?? selectedFilterOptionTeacher
        selectedStatusFilterOptionTeacher = statusFilterOptionTeacher ?? selectedStatusFilterOptionTeacher

        if isTeacher {
            isFilterIconSolid = selectedGradingPeriodId != defaultGradingPeriodId || isFilteringCustom
        } else {
            isFilterIconSolid = selectedGradingPeriodId != defaultGradingPeriodId || (isFilteringCustom && selectedFilterOptionsStudent != initialFilterOptionsStudent)
        }

        assignmentGroups = env.subscribe(GetAssignmentsByGroup(courseID: courseID, gradingPeriodID: selectedGradingPeriodId)) { [weak self] in
            self?.assignmentGroupsDidUpdate()
        }
    }

    private func assignmentGroupsDidUpdate() {
        guard let assignmentGroups else { return }
        if !assignmentGroups.requested || assignmentGroups.pending || !gradingPeriods.requested || gradingPeriods.pending { return }

        isShowingGradingPeriods = gradingPeriods.count > 1
        var assignmentGroupViewModels: [AssignmentGroupViewModel] = []
        let assignments: [Assignment]
        let compactAssignmentGroups = assignmentGroups.compactMap { $0 }
        let sortedAssignmentGroups = compactAssignmentGroups.sorted { $0.dueAt ?? Date.distantFuture < $1.dueAt ?? Date.distantFuture }
        assignments = isTeacher ? filterAssignmentsTeacher(sortedAssignmentGroups) : filterAssignments(sortedAssignmentGroups)

        switch selectedSortingOption {
        case .groupName, .assignmentGroup:
            for section in 0..<(assignmentGroups.sections?.count ?? 0) {
                if let group = assignmentGroups[IndexPath(row: 0, section: section)]?.assignmentGroup {
                    let groupAssignments: [Assignment] = assignments.filter { $0.assignmentGroup == group }
                    if !groupAssignments.isEmpty {
                        assignmentGroupViewModels.append(AssignmentGroupViewModel(
                            assignmentGroup: group,
                            assignments: groupAssignments,
                            courseColor: courseColor
                        ))
                    }
                }
            }
        case .dueDate:
            let rightNow = Clock.now

            let overdue = assignments.filter { $0.dueAt ?? Date.distantFuture < rightNow }
            if !overdue.isEmpty {
                let overdueGroup = AssignmentDateGroup(id: "overdue", name: "Overdue Assignments", assignments: overdue)
                assignmentGroupViewModels.append(AssignmentGroupViewModel(assignmentDateGroup: overdueGroup, courseColor: courseColor))
            }
            let upcoming = assignments.filter { $0.dueAt ?? Date.distantPast > rightNow }
            if !upcoming.isEmpty {
                let upcomingGroup = AssignmentDateGroup(id: "upcoming", name: "Upcoming Assignments", assignments: upcoming)
                assignmentGroupViewModels.append(AssignmentGroupViewModel(assignmentDateGroup: upcomingGroup, courseColor: courseColor))
            }
            let undated = assignments.filter { $0.dueAt == nil }
            if !undated.isEmpty {
                let undatedGroup = AssignmentDateGroup(id: "undated", name: "Undated Assignments", assignments: undated)
                assignmentGroupViewModels.append(AssignmentGroupViewModel(assignmentDateGroup: undatedGroup, courseColor: courseColor))
            }
        case .assignmentType:
            let normal = assignments.filter { $0.quizID == nil && !$0.isLTIAssignment && !$0.isDiscussion }
            if !normal.isEmpty {
                let normalGroup = AssignmentDateGroup(id: "normal", name: "Assignments", assignments: normal)
                assignmentGroupViewModels.append(AssignmentGroupViewModel(assignmentDateGroup: normalGroup, courseColor: courseColor))
            }
            let discussions = assignments.filter { $0.isDiscussion }
            if !discussions.isEmpty {
                let discussionsGroup = AssignmentDateGroup(id: "discussions", name: "Discussions", assignments: discussions)
                assignmentGroupViewModels.append(AssignmentGroupViewModel(assignmentDateGroup: discussionsGroup, courseColor: courseColor))
            }
            let quizzes = assignments.filter { $0.quizID != nil || $0.isQuizLTI }
            if !quizzes.isEmpty {
                let quizzesGroup = AssignmentDateGroup(id: "quizzes", name: "Quiz", assignments: quizzes)
                assignmentGroupViewModels.append(AssignmentGroupViewModel(assignmentDateGroup: quizzesGroup, courseColor: courseColor))
            }
            let lti = assignments.filter { $0.isLTIAssignment && !$0.isQuizLTI }
            if !lti.isEmpty {
                let ltiGroup = AssignmentDateGroup(id: "lti", name: "LTI", assignments: lti)
                assignmentGroupViewModels.append(AssignmentGroupViewModel(assignmentDateGroup: ltiGroup, courseColor: courseColor))
            }
        }

        state = (assignmentGroupViewModels.isEmpty ? .empty : .data(assignmentGroupViewModels))
    }

    private func filterAssignments(_ assignments: [Assignment]) -> [Assignment] {
        // all filter selected is the same as no filter selected
        guard isFilteringCustom else {
            return assignments
        }
        var filteredAssignments: [Assignment] = []

        assignments.forEach { assignment in
            selectedFilterOptionsStudent.forEach { filterOption in
                if !filteredAssignments.contains(assignment), filterOption.rule(assignment) {
                    filteredAssignments.append(assignment)
                }
            }
        }

        return filteredAssignments
    }

    private func filterAssignmentsTeacher(_ assignments: [Assignment]) -> [Assignment] {
        var filteredAssignments: [Assignment] = []

        assignments.forEach { assignment in
            if !filteredAssignments.contains(assignment), selectedFilterOptionTeacher.rule(assignment), selectedStatusFilterOptionTeacher.rule(assignment) {
                filteredAssignments.append(assignment)
            }
        }

        return filteredAssignments
    }

    private func courseDidUpdate() {
        courseColor = course.first?.color
        courseName = course.first?.name

        defaultDetailViewRoute = {
            var result = "/empty"

            if let color = courseColor {
                result.append("?contextColor=\(color.hexString.dropFirst())")
            }

            return result
        }()
    }

    func navigateToPreferences(viewController: WeakViewController) {
        let viewModel = AssignmentListPreferencesViewModel(
            isTeacher: isTeacher,
            initialFilterOptionsStudent: selectedFilterOptionsStudent,
            initialStatusFilterOptionTeacher: selectedStatusFilterOptionTeacher,
            initialFilterOptionTeacher: selectedFilterOptionTeacher,
            sortingOptions: sortingOptions,
            initialSortingOption: selectedSortingOption,
            gradingPeriods: gradingPeriods.compactMap { $0 },
            initialGradingPeriod: gradingPeriods.filter { $0.id == selectedGradingPeriodId }.first,
            courseName: courseName ?? "",
            env: env,
            completion: { [weak self] assignmentListPreferences in
                guard let self else { return }
                filterOptionsDidUpdate(
                    filterOptionsStudent: assignmentListPreferences.filterOptionsStudent,
                    filterOptionTeacher: assignmentListPreferences.filterOptionTeacher,
                    statusFilterOptionTeacher: assignmentListPreferences.statusFilterOptionTeacher,
                    sortingOption: assignmentListPreferences.sortingOption,
                    gradingPeriodId: assignmentListPreferences.gradingPeriodId
                )
                assignmentGroups?.refresh()
                saveAssignmentListPreferences()
            })
        let controller = CoreHostingController(AssignmentListPreferencesScreen(viewModel: viewModel))
        env.router.show(
            controller,
            from: viewController,
            options: .modal(
                .automatic,
                isDismissable: true,
                embedInNav: true,
                addDoneButton: false,
                animated: true
            )
        )
    }

    private func loadAssignmentListPreferences() {
        guard let filterSettingsData = userDefaults?.assignmentListStudentFilterSettingsByCourseId?[courseID] else {
            return
        }

        guard let customFilterSettingData = userDefaults?.assignmentListTeacherFilterSettingByCourseId?[courseID] else {
            return
        }

        guard let statusFilterSettingData = userDefaults?.assignmentListTeacherStatusFilterSettingByCourseId?[courseID] else {
            return
        }

        guard let groupBySettingData = userDefaults?.assignmentListGroupBySettingByCourseId?[courseID] else {
            return
        }

        selectedFilterOptionsStudent = AssignmentFilterOptionStudent.allCases.filter { filterSettingsData.contains($0.id) }

        selectedFilterOptionTeacher = AssignmentFilterOptionsTeacher.allCases.filter {
            customFilterSettingData == $0.rawValue
        }.first ?? selectedFilterOptionTeacher

        selectedStatusFilterOptionTeacher = AssignmentStatusFilterOptionsTeacher.allCases.filter {
            statusFilterSettingData == $0.rawValue
        }.first ?? selectedStatusFilterOptionTeacher

        selectedSortingOption = sortingOptions.filter { groupBySettingData == $0.rawValue }.first ?? selectedSortingOption
    }

    private func saveAssignmentListPreferences() {
        let selectedStudentFilterOptionIds = selectedFilterOptionsStudent.map { $0.id }
        if userDefaults?.assignmentListStudentFilterSettingsByCourseId == nil {
            userDefaults?.assignmentListStudentFilterSettingsByCourseId = [courseID: selectedStudentFilterOptionIds]
        } else {
            userDefaults?.assignmentListStudentFilterSettingsByCourseId?[courseID] = selectedStudentFilterOptionIds
        }

        let selectedFilterOptionTeacherId = selectedFilterOptionTeacher.rawValue
        if userDefaults?.assignmentListTeacherFilterSettingByCourseId == nil {
            userDefaults?.assignmentListTeacherFilterSettingByCourseId = [courseID: selectedFilterOptionTeacherId]
        } else {
            userDefaults?.assignmentListTeacherFilterSettingByCourseId?[courseID] = selectedFilterOptionTeacherId
        }

        let selectedStatusFilterOptionTeacherId = selectedStatusFilterOptionTeacher.rawValue
        if userDefaults?.assignmentListTeacherStatusFilterSettingByCourseId == nil {
            userDefaults?.assignmentListTeacherStatusFilterSettingByCourseId = [courseID: selectedStatusFilterOptionTeacherId]
        } else {
            userDefaults?.assignmentListTeacherStatusFilterSettingByCourseId?[courseID] = selectedStatusFilterOptionTeacherId
        }

        let selectedGroupByOptionId = selectedSortingOption.rawValue
        if userDefaults?.assignmentListGroupBySettingByCourseId == nil {
            userDefaults?.assignmentListGroupBySettingByCourseId = [courseID: selectedGroupByOptionId]
        } else {
            userDefaults?.assignmentListGroupBySettingByCourseId?[courseID] = selectedGroupByOptionId
        }
    }

    // MARK: - Preview Support

#if DEBUG

    init(state: ViewModelState<[AssignmentGroupViewModel]>) {
        self.env = .shared
        self.courseID = ""
        self.state = state
        self.defaultGradingPeriodId = nil
        self.defaultSortingOption = AppEnvironment.shared.app == .teacher ? .assignmentType : .dueDate
        self.selectedSortingOption = AppEnvironment.shared.app == .teacher ? .assignmentType : .dueDate
        self.isTeacher = AppEnvironment.shared.app == .teacher
        self.sortingOptions = AppEnvironment.shared.app == .teacher ? AssignmentArrangementOptions.teacherCases : AssignmentArrangementOptions.studentCases
    }

#endif
}

extension AssignmentListViewModel: Refreshable {

    @available(*, renamed: "refresh()")
    public func refresh(completion: @escaping () -> Void) {
        Task {
            await refresh()
            completion()
        }
    }

    public func refresh() async {
        return await withCheckedContinuation { continuation in
            assignmentGroups?.refresh(force: true) { _ in
                continuation.resume()
            }
        }
    }
}
