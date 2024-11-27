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

    public enum AssignmentArrangementOptions: String, CaseIterable {
        static let studentCases: [Self] = [.dueDate, .groupName]
        static let teacherCases: [Self] = [.assignmentGroup, .assignmentType, .availability]

        case dueDate
        case groupName
        case assignmentGroup
        case assignmentType
        case availability

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
            case .availability:
                return String(localized: "Availability", bundle: .core)
            }
        }
    }

    public enum AssignmentArrangementOptionsTeacher: String, CaseIterable {
        case assignmentGroup
        case assignmentType
        case availability

        var title: String {
            switch self {
            case .assignmentGroup:
                return String(localized: "Assignment Group", bundle: .core)
            case .assignmentType:
                return String(localized: "Assignment Type", bundle: .core)
            case .availability:
                return String(localized: "Availability", bundle: .core)
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
    private var initialFilterOptions: [AssignmentFilterOption] = AssignmentFilterOption.allCases
    private var selectedFilterOptions: [AssignmentFilterOption] = AssignmentFilterOption.allCases

    // Teacher
    private let filterOptionsTeacher: [AssignmentFilterOptionsTeacher] = AssignmentFilterOptionsTeacher.customFilters
    private var selectedFilterOption: AssignmentFilterOptionsTeacher = .allAssignments
    private let statusFilterOptions: [AssignmentFilterOptionsTeacher] = AssignmentFilterOptionsTeacher.statusFilters
    private var initialStatusFilterOption: AssignmentFilterOptionsTeacher = .allAssignments
    private var selectedStatusFilterOption: AssignmentFilterOptionsTeacher = .allAssignments
    private var initialFilterOptionTeacher: AssignmentFilterOptionsTeacher = .allAssignments
    private var selectedFilterOptionTeacher: AssignmentFilterOptionsTeacher = .allAssignments

    private var isFilteringCustom: Bool {
        if isTeacher {
            return !(selectedFilterOptionTeacher == initialFilterOptionTeacher && selectedStatusFilterOption == initialStatusFilterOption)
        } else {
            // all filters selected is the same as no filter selected
            return (!selectedFilterOptions.isEmpty) && selectedFilterOptions.count != AssignmentFilterOption.allCases.count
        }
    }

    private let env = AppEnvironment.shared
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
        context: Context,
        userDefaults: SessionDefaults? = AppEnvironment.shared.userDefaults
    ) {
        self.isTeacher = env.app == .teacher
        self.sortingOptions = isTeacher ? AssignmentArrangementOptions.teacherCases : AssignmentArrangementOptions.studentCases
        self.defaultSortingOption = isTeacher ? .assignmentGroup : .dueDate
        self.selectedSortingOption = defaultSortingOption
        self.userDefaults = userDefaults
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
        filterOptionsDidUpdate(filterOptions: selectedFilterOptions, gradingPeriodId: selectedGradingPeriodId)
        assignmentGroups?.refresh()
    }

    func filterOptionsDidUpdate(
        filterOptions: [AssignmentFilterOption]? = nil,
        filterOptionTeacher: AssignmentFilterOptionsTeacher? = nil,
        statusFilterOption: AssignmentFilterOptionsTeacher? = nil,
        sortingOption: AssignmentArrangementOptions? = nil,
        gradingPeriodId: String?
    ) {
        if gradingPeriodId == selectedGradingPeriodId
            && sortingOption == selectedSortingOption
            && filterOptions == selectedFilterOptions
            && filterOptionTeacher == selectedFilterOptionTeacher
            && statusFilterOption == selectedStatusFilterOption {
            return
        }

        selectedGradingPeriodId = gradingPeriodId
        selectedSortingOption = sortingOption ?? selectedSortingOption
        selectedFilterOptions = filterOptions ?? selectedFilterOptions
        selectedFilterOptionTeacher = filterOptionTeacher ?? selectedFilterOptionTeacher
        selectedStatusFilterOption = statusFilterOption ?? selectedStatusFilterOption

        if isTeacher {
            isFilterIconSolid = selectedGradingPeriodId != defaultGradingPeriodId || isFilteringCustom
        } else {
            isFilterIconSolid = selectedGradingPeriodId != defaultGradingPeriodId || (isFilteringCustom && selectedFilterOptions != initialFilterOptions)
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
            let quizzes = assignments.filter { $0.quizID != nil }
            if !quizzes.isEmpty {
                let quizzesGroup = AssignmentDateGroup(id: "quizzes", name: "Quiz", assignments: quizzes)
                assignmentGroupViewModels.append(AssignmentGroupViewModel(assignmentDateGroup: quizzesGroup, courseColor: courseColor))
            }
            let lti = assignments.filter { $0.isLTIAssignment && $0.quizID == nil }
            if !lti.isEmpty {
                let ltiGroup = AssignmentDateGroup(id: "lti", name: "LTI", assignments: lti)
                assignmentGroupViewModels.append(AssignmentGroupViewModel(assignmentDateGroup: ltiGroup, courseColor: courseColor))
            }
        case .availability:
            let available = assignments.filter { $0.lockStatus == .unlocked && $0.published }
            if !available.isEmpty {
                let availableGroup = AssignmentDateGroup(id: "available", name: "Available", assignments: available)
                assignmentGroupViewModels.append(AssignmentGroupViewModel(assignmentDateGroup: availableGroup, courseColor: courseColor))
            }
            let closed = assignments.filter { $0.inClosedGradingPeriod }
            if !closed.isEmpty {
                let closedGroup = AssignmentDateGroup(id: "closed", name: "Closed", assignments: closed)
                assignmentGroupViewModels.append(AssignmentGroupViewModel(assignmentDateGroup: closedGroup, courseColor: courseColor))
            }
            let unpublished = assignments.filter { !$0.published }
            if !unpublished.isEmpty {
                let unpublishedGroup = AssignmentDateGroup(id: "unpublished", name: "Unpublished", assignments: unpublished)
                assignmentGroupViewModels.append(AssignmentGroupViewModel(assignmentDateGroup: unpublishedGroup, courseColor: courseColor))
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
            selectedFilterOptions.forEach { filterOption in
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
            if !filteredAssignments.contains(assignment), selectedFilterOptionTeacher.rule(assignment), selectedStatusFilterOption.rule(assignment) {
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
            initialFilterOptions: selectedFilterOptions,
            initialStatusFilterOption: selectedStatusFilterOption,
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
                    filterOptions: assignmentListPreferences.filterOptions,
                    filterOptionTeacher: assignmentListPreferences.filterOptionTeacher,
                    statusFilterOption: assignmentListPreferences.statusFilterOption,
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
        guard let filterSettingsData = userDefaults?.assignmentListFilterSettingsByCourseId?[courseID] else {
            return
        }

        guard let customFilterSettingData = userDefaults?.assignmentListCustomFilterSettingByCourseId?[courseID] else {
            return
        }

        guard let statusFilterSettingData = userDefaults?.assignmentListStatusFilterSettingByCourseId?[courseID] else {
            return
        }

        guard let groupBySettingData = userDefaults?.assignmentListGroupBySettingByCourseId?[courseID] else {
            return
        }

        selectedFilterOptions = AssignmentFilterOption.allCases.filter { filterSettingsData.contains($0.id) }

        selectedFilterOptionTeacher = AssignmentFilterOptionsTeacher.allCases.filter {
            customFilterSettingData == $0.rawValue
        }.first ?? selectedFilterOptionTeacher

        selectedStatusFilterOption = AssignmentFilterOptionsTeacher.allCases.filter {
            statusFilterSettingData == $0.rawValue
        }.first ?? selectedStatusFilterOption

        selectedSortingOption = sortingOptions.filter { groupBySettingData == $0.rawValue }.first ?? selectedSortingOption
    }

    private func saveAssignmentListPreferences() {
        let selectedFilterOptionIds = selectedFilterOptions.map { $0.id }
        if userDefaults?.assignmentListFilterSettingsByCourseId == nil {
            userDefaults?.assignmentListFilterSettingsByCourseId = [courseID: selectedFilterOptionIds]
        } else {
            userDefaults?.assignmentListFilterSettingsByCourseId?[courseID] = selectedFilterOptionIds
        }

        let selectedCustomFilterOptionId = selectedFilterOptionTeacher.rawValue
        if userDefaults?.assignmentListCustomFilterSettingByCourseId == nil {
            userDefaults?.assignmentListCustomFilterSettingByCourseId = [courseID: selectedCustomFilterOptionId]
        } else {
            userDefaults?.assignmentListCustomFilterSettingByCourseId?[courseID] = selectedCustomFilterOptionId
        }

        let selectedStatusFilterOptionId = selectedStatusFilterOption.rawValue
        if userDefaults?.assignmentListStatusFilterSettingByCourseId == nil {
            userDefaults?.assignmentListStatusFilterSettingByCourseId = [courseID: selectedStatusFilterOptionId]
        } else {
            userDefaults?.assignmentListStatusFilterSettingByCourseId?[courseID] = selectedStatusFilterOptionId
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
