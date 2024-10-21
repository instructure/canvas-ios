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

public class AssignmentListViewModel: ObservableObject {
    public enum ViewModelState<T: Equatable>: Equatable {
        case loading
        case empty
        case data(T)
    }

    private struct AssignmentListPreferenceSettings: Codable {
        let filterOptionIds: [String]
        let sortingOptionId: String
    }

    // MARK: - Outputs

    @Published public private(set) var state: ViewModelState<[AssignmentGroupViewModel]> = .loading
    @Published public private(set) var courseColor: UIColor?
    @Published public private(set) var courseName: String?
    @Published public private(set) var defaultDetailViewRoute = "/empty"
    @Published public private(set) var isShowingGradingPeriods: Bool = false

    // MARK: - Variables

    public var isFilterIconFilled: Bool = false
    public var defaultGradingPeriod: GradingPeriod?
    public let defaultSortingOption: AssignmentArrangementOptions = .dueDate
    public var selectedGradingPeriod: GradingPeriod?
    public var selectedSortingOption: AssignmentArrangementOptions = .dueDate
    private var sortingOptions = AssignmentArrangementOptions.allCases
    private var selectedFilterOptions: [AssignmentFilterOption] = AssignmentFilterOption.allCases
    private let env = AppEnvironment.shared
    private var userDefaults: SessionDefaults?
    private var assignmentListPreferenceSettings: AssignmentListPreferenceSettings?
    let courseID: String

    public private(set) lazy var gradingPeriods: Store<LocalUseCase<GradingPeriod>> = {
        let scope: Scope = .where(
            #keyPath(GradingPeriod.courseID),
            equals: courseID,
            orderBy: #keyPath(GradingPeriod.startDate)
        )
        return env.subscribe(LocalUseCase(scope: scope)) { }
    }()

    private lazy var assignmentGroups = env.subscribe(
            GetAssignmentsByGroup(courseID: courseID, gradingPeriodID: defaultGradingPeriod?.id)
        ) { [weak self] in
            self?.assignmentGroupsDidUpdate()
        }

    private lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.courseDidUpdate()
    }

    /** This is required for the router to help decide if the hybrid discussion details or the native one should be launched. */
    private lazy var featureFlags = env.subscribe(GetEnabledFeatureFlags(context: .course(courseID)))

    // MARK: - Init
    public init(context: Context, userDefaults: SessionDefaults? = AppEnvironment.shared.userDefaults) {
        self.userDefaults = userDefaults
        self.courseID = context.id
        self.selectedGradingPeriod = self.defaultGradingPeriod

        loadAssignmentListPreferenceSettings()
        featureFlags.refresh()
    }

    // MARK: - Functions

    public func filterOptionsDidUpdate(
        gradingPeriod: GradingPeriod?,
        sortingOption: AssignmentArrangementOptions? = nil,
        filterOptions: [AssignmentFilterOption]? = nil
    ) {
        if gradingPeriod == selectedGradingPeriod && sortingOption == selectedSortingOption && filterOptions == selectedFilterOptions {
            return
        }

        selectedGradingPeriod = gradingPeriod
        selectedSortingOption = sortingOption ?? selectedSortingOption
        selectedFilterOptions = filterOptions ?? selectedFilterOptions

        isFilterIconFilled = gradingPeriod != defaultGradingPeriod || sortingOption != defaultSortingOption

        assignmentGroups = env.subscribe(GetAssignmentsByGroup(courseID: courseID, gradingPeriodID: gradingPeriod?.id)) { [weak self] in
            self?.assignmentGroupsDidUpdate()
        }
        assignmentGroups.refresh()
    }

    public func viewDidAppear() {
        gradingPeriods.refresh()
        filterOptionsDidUpdate(gradingPeriod: defaultGradingPeriod)
        course.refresh()
        assignmentGroups.refresh(force: true)
    }

    private func assignmentGroupsDidUpdate() {
        if !assignmentGroups.requested || assignmentGroups.pending { return }

        isShowingGradingPeriods = assignmentGroups.count > 1
        var assignmentGroups: [AssignmentGroupViewModel] = []
        let assignments: [Assignment] = filterAssignments(self.assignmentGroups.compactMap { $0 })

        switch selectedSortingOption {
        case .groupName:
            for section in 0..<(self.assignmentGroups.sections?.count ?? 0) {
                if let group = self.assignmentGroups[IndexPath(row: 0, section: section)]?.assignmentGroup {
                    let groupAssignments: [Assignment] = assignments.filter { $0.assignmentGroup == group }
                    if !groupAssignments.isEmpty {
                        assignmentGroups.append(AssignmentGroupViewModel(
                            assignmentGroup: group,
                            assignments: groupAssignments,
                            courseColor: courseColor
                        ))
                    }
                }
            }
        case .dueDate:
            let overdue = assignments.filter { $0.dueAt ?? Date.distantFuture < Date.now }
            if !overdue.isEmpty {
                let overdueGroup = AssignmentDateGroup(id: "overdue", name: "Overdue Assignments", assignments: overdue)
                assignmentGroups.append(AssignmentGroupViewModel(assignmentDateGroup: overdueGroup, courseColor: courseColor))
            }
            let upcoming = assignments.filter { $0.dueAt ?? Date.distantPast > Date.now }
            if !upcoming.isEmpty {
                let upcomingGroup = AssignmentDateGroup(id: "upcoming", name: "Upcoming Assignments", assignments: upcoming)
                assignmentGroups.append(AssignmentGroupViewModel(assignmentDateGroup: upcomingGroup, courseColor: courseColor))
            }
            let undated = assignments.filter { $0.dueAt == nil }
            if !undated.isEmpty {
                let undatedGroup = AssignmentDateGroup(id: "undated", name: "Undated Assignments", assignments: undated)
                assignmentGroups.append(AssignmentGroupViewModel(assignmentDateGroup: undatedGroup, courseColor: courseColor))
            }
        }

        state = (assignmentGroups.isEmpty ? .empty : .data(assignmentGroups))
    }

    private func filterAssignments(_ assignments: [Assignment]) -> [Assignment] {
        var filteredAssignments: [Assignment] = []

        // all filter selected is the same as no filter selected
        if selectedFilterOptions.count == AssignmentFilterOption.allCases.count || selectedFilterOptions.isEmpty {
            return assignments
        }

        assignments.forEach { assignment in
            selectedFilterOptions.forEach { filterOption in
                if let submission = assignment.submission, !filteredAssignments.contains(assignment), filterOption.submissionRule(submission) {
                    filteredAssignments.append(assignment)
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

    func navigateToFilter(viewController: WeakViewController) {
        let weakVC = WeakViewController()
        let viewModel = AssignmentFilterViewModel(
            gradingPeriods: gradingPeriods.all,
            initialGradingPeriod: selectedGradingPeriod,
            sortingOptions: sortingOptions,
            initialSortingOption: selectedSortingOption,
            initialFilterOptions: selectedFilterOptions,
            courseId: courseID,
            courseName: courseName,
            completion: { [weak self] assignmentListPreferences in
                self?.filterOptionsDidUpdate(
                    gradingPeriod: assignmentListPreferences.gradingPeriod,
                    sortingOption: assignmentListPreferences.sortingOption,
                    filterOptions: assignmentListPreferences.filterOptions
                )
                self?.saveAssignmentListPreferenceSettings()
            })
        let controller = CoreHostingController(AssignmentFilterScreen(viewModel: viewModel))
        weakVC.setValue(controller)
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

    private func loadAssignmentListPreferenceSettings() {
        guard let settingsData = userDefaults?.selectedAssignmentListPreferenceSettingsByCourseId?[courseID] else {
            return
        }

        assignmentListPreferenceSettings = try? JSONDecoder().decode(AssignmentListPreferenceSettings.self, from: settingsData)

        selectedFilterOptions = AssignmentFilterOption.allCases.filter {
            assignmentListPreferenceSettings?.filterOptionIds.contains($0.id) ?? false
        }

        selectedSortingOption = sortingOptions.filter {
            assignmentListPreferenceSettings?.sortingOptionId == $0.rawValue
        }.first ?? selectedSortingOption
    }

    private func saveAssignmentListPreferenceSettings() {
        assignmentListPreferenceSettings = AssignmentListPreferenceSettings(
            filterOptionIds: selectedFilterOptions.map { $0.id },
            sortingOptionId: selectedSortingOption.rawValue
        )

        guard let encodedData = try? JSONEncoder().encode(assignmentListPreferenceSettings) else {
            return
        }

        if userDefaults?.selectedAssignmentListPreferenceSettingsByCourseId == nil {
            userDefaults?.selectedAssignmentListPreferenceSettingsByCourseId = [courseID: encodedData]
        } else {
            userDefaults?.selectedAssignmentListPreferenceSettingsByCourseId?[courseID] = encodedData
        }
    }

    // MARK: - Preview Support

#if DEBUG

    init(state: ViewModelState<[AssignmentGroupViewModel]>) {
        self.courseID = ""
        self.state = state
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
