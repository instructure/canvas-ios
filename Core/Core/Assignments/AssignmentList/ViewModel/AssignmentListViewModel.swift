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
        case dueDate
        case groupName

        var title: String {
            switch self {
            case .dueDate:
                return String(localized: "Due Date", bundle: .core)
            case .groupName:
                return String(localized: "Group", bundle: .core)
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
    public var defaultGradingPeriod: GradingPeriod?
    public let defaultSortingOption: AssignmentArrangementOptions = .dueDate
    public var selectedGradingPeriod: GradingPeriod?
    public var selectedSortingOption: AssignmentArrangementOptions = .dueDate

    // MARK: - Private properties

    private let sortingOptions = AssignmentArrangementOptions.allCases
    private var initialFilterOptions: [AssignmentFilterOption] = AssignmentFilterOption.allCases
    private var selectedFilterOptions: [AssignmentFilterOption] = AssignmentFilterOption.allCases

    private var isFilteringCustom: Bool {
        // all filters selected is the same as no filter selected
        (!selectedFilterOptions.isEmpty) && selectedFilterOptions.count != AssignmentFilterOption.allCases.count
    }

    private let env = AppEnvironment.shared
    private var userDefaults: SessionDefaults?
    let courseID: String

    private lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.courseDidUpdate()
    }

    private lazy var gradingPeriods = env.subscribe(GetGradingPeriods(courseID: courseID)) { [weak self] in
        guard let self else { return }
        if selectedGradingPeriod == nil {
            defaultGradingPeriod = currentGradingPeriod
            selectedGradingPeriod = defaultGradingPeriod
        }
        filterOptionsDidUpdate(filterOptions: selectedFilterOptions, gradingPeriod: selectedGradingPeriod)
        assignmentGroups.refresh()
    }

    private lazy var assignmentGroups = env.subscribe(GetAssignmentGroups(courseID: courseID)) { [weak self] in
        self?.assignmentGroupsDidUpdate()
    }

    /** This is required for the router to help decide if the hybrid discussion details or the native one should be launched. */
    private lazy var featureFlags = env.subscribe(GetEnabledFeatureFlags(context: .course(courseID)))

    private var currentGradingPeriod: GradingPeriod? {
        gradingPeriods.filter {
            let rightNow = Clock.now
            if let start = $0.startDate, let end = $0.endDate {
                return start < rightNow && end > rightNow
            }
            return false
        }
        .first
    }

    // MARK: - Init
    public init(
        context: Context,
        userDefaults: SessionDefaults? = AppEnvironment.shared.userDefaults
    ) {
        self.userDefaults = userDefaults
        self.courseID = context.id

        featureFlags.refresh()
    }

    // MARK: - Functions

    public func viewDidAppear() {
        loadAssignmentListPreferences()
        course.refresh(force: true)
        gradingPeriods.refresh(force: true)

        isFilterIconSolid = isFilteringCustom || selectedGradingPeriod != defaultGradingPeriod
    }

    public func filterOptionsDidUpdate(
        filterOptions: [AssignmentFilterOption]? = nil,
        sortingOption: AssignmentArrangementOptions? = nil,
        gradingPeriod: GradingPeriod?
    ) {
        if gradingPeriod == selectedGradingPeriod
            && sortingOption == selectedSortingOption
            && filterOptions == selectedFilterOptions {
            return
        }

        selectedGradingPeriod = gradingPeriod
        selectedSortingOption = sortingOption ?? selectedSortingOption
        selectedFilterOptions = filterOptions ?? selectedFilterOptions

        isFilterIconSolid = gradingPeriod != defaultGradingPeriod || (isFilteringCustom && selectedFilterOptions != initialFilterOptions)

        assignmentGroupsDidUpdate()
    }

    private func assignmentGroupsDidUpdate() {
        if !assignmentGroups.requested || assignmentGroups.pending { return }
        if !gradingPeriods.requested || gradingPeriods.pending { return }

        isShowingGradingPeriods = gradingPeriods.count > 1
        var assignmentGroupViewModels: [AssignmentGroupViewModel] = []
        let compactAssignmentGroups = assignmentGroups
            .compactMap { $0.assignments }
            .map { Array($0) }
            .flatMap { $0 }
        let assignments: [Assignment] = filterAssignments(compactAssignmentGroups)

        switch selectedSortingOption {
        case .groupName:
            assignmentGroups.forEach { group in
                let groupAssignments: [Assignment] = assignments.filter { $0.assignmentGroup == group }
                guard !groupAssignments.isEmpty else { return }
                assignmentGroupViewModels.append(AssignmentGroupViewModel(
                    assignmentGroup: group,
                    assignments: groupAssignments,
                    courseColor: courseColor
                ))
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
        }

        state = (assignmentGroupViewModels.isEmpty ? .empty : .data(assignmentGroupViewModels))
    }

    private func filterAssignments(_ assignments: [Assignment]) -> [Assignment] {
        // Filtering by grading period except if "All" is selected (nil)
        var filteredAssignments = assignments
        if let selectedGradingPeriod {
            filteredAssignments = filteredAssignments.filter { $0.submission?.gradingPeriodId == selectedGradingPeriod.id }
        }

        // all filter selected is the same as no filter selected
        guard isFilteringCustom else {
            return filteredAssignments
        }

        filteredAssignments.forEach { assignment in
            selectedFilterOptions.forEach { filterOption in
                if let indexOfAssignment = filteredAssignments.firstIndex(of: assignment), !filterOption.rule(assignment) {
                    filteredAssignments.remove(at: indexOfAssignment)
                }
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
            initialFilterOptions: selectedFilterOptions,
            sortingOptions: sortingOptions,
            initialSortingOption: selectedSortingOption,
            gradingPeriods: gradingPeriods.all,
            initialGradingPeriod: selectedGradingPeriod,
            courseName: courseName ?? "",
            env: env,
            completion: { [weak self] assignmentListPreferences in
                self?.filterOptionsDidUpdate(
                    filterOptions: assignmentListPreferences.filterOptions,
                    sortingOption: assignmentListPreferences.sortingOption,
                    gradingPeriod: assignmentListPreferences.gradingPeriod
                )
                self?.saveAssignmentListPreferences()
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

        guard let groupBySettingData = userDefaults?.assignmentListGroupBySettingByCourseId?[courseID] else {
            return
        }

        selectedFilterOptions = AssignmentFilterOption.allCases.filter { filterSettingsData.contains($0.id) }

        selectedSortingOption = sortingOptions.filter { groupBySettingData == $0.rawValue }.first ?? selectedSortingOption
    }

    private func saveAssignmentListPreferences() {
        let selectedFilterOptionIds = selectedFilterOptions.map { $0.id }
        if userDefaults?.assignmentListFilterSettingsByCourseId == nil {
            userDefaults?.assignmentListFilterSettingsByCourseId = [courseID: selectedFilterOptionIds]
        } else {
            userDefaults?.assignmentListFilterSettingsByCourseId?[courseID] = selectedFilterOptionIds
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
        self.defaultGradingPeriod = nil
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
            assignmentGroups.refresh(force: true) { _ in
                continuation.resume()
            }
        }
    }
}
