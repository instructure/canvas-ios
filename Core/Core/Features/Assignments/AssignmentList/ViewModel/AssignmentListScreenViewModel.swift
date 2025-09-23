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

import Combine
import CombineSchedulers
import SwiftUI

// MARK: - ViewModel

public class AssignmentListScreenViewModel: ObservableObject {

    public enum GroupingOptions: String, CaseIterable {
        static let studentCases: [Self] = [.dueDate, .groupName]
        static let teacherCases: [Self] = [.assignmentGroup, .assignmentType]

        case dueDate
        case groupName
        case assignmentGroup
        case assignmentType
    }

    // MARK: - Outputs

    @Published public private(set) var state: InstUI.ScreenState = .loading
    @Published private(set) var sections: [AssignmentListSection] = []
    @Published public private(set) var courseColor: UIColor?
    @Published public private(set) var courseName: String?
    @Published public private(set) var defaultDetailViewRoute = "/empty"

    public var isFilterIconSolid: Bool = false
    public var defaultGradingPeriodId: String?
    public let defaultSortingOption: GroupingOptions
    public var selectedGradingPeriodId: String?
    public var selectedGradingPeriodTitle: String? { gradingPeriods.filter({ $0.id == selectedGradingPeriodId }).first?.title }
    public var wasCurrentPeriodPreselected: Bool = false
    public var selectedSortingOption: GroupingOptions

    // MARK: - Inputs

    let didSelectAssignment = PassthroughSubject<(URL?, WeakViewController), Never>()

    // MARK: - Private properties

    private let isTeacher: Bool
    private let sortingOptions: [GroupingOptions]
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
    private var subscriptions = Set<AnyCancellable>()
    private var userDefaults: SessionDefaults?
    let courseID: String

    // MARK: - Stores

    private lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.courseDidUpdate()
    }

    private lazy var gradingPeriods = env.subscribe(GetGradingPeriods(courseID: courseID)) { [weak self] in
        self?.gradingPeriodsDidUpdate()
    }

    private var assignmentGroups: Store<GetAssignmentsByGroup>?
    private var wasAssignmentGroupsUpdated: Bool = false

    /** This is required for the router to help decide if the hybrid discussion details or the native one should be launched. */
    private lazy var featureFlags = env.subscribe(GetEnabledFeatureFlags(context: .course(courseID)))

    // MARK: - Init

    public init(
        env: AppEnvironment,
        context: Context,
        userDefaults: SessionDefaults? = nil,
        defaultGradingPeriod: GradingPeriod? = nil,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.env = env
        self.userDefaults = userDefaults ?? env.userDefaults
        self.isTeacher = env.app == .teacher
        self.sortingOptions = isTeacher ? GroupingOptions.teacherCases : GroupingOptions.studentCases
        self.defaultSortingOption = isTeacher ? .assignmentGroup : .dueDate
        self.selectedSortingOption = defaultSortingOption
        self.courseID = context.id

        loadAssignmentListPreferences()
        featureFlags.refresh()
        course.refresh()
        gradingPeriods.refresh()

        didSelectAssignment
            .receive(on: scheduler)
            .sink { url, controller in
                guard let url else { return }
                env.router.route(to: url, from: controller, options: .detail)
            }
            .store(in: &subscriptions)
    }

    // MARK: - Functions

    func viewDidAppear() {
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
    }

    func filterOptionsDidUpdate(
        filterOptionsStudent: [AssignmentFilterOptionStudent]? = nil,
        filterOptionTeacher: AssignmentFilterOptionsTeacher? = nil,
        statusFilterOptionTeacher: AssignmentStatusFilterOptionsTeacher? = nil,
        sortingOption: GroupingOptions? = nil,
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

        assignmentGroups = env.subscribe(GetAssignmentsByGroup(courseID: courseID.localID, gradingPeriodID: selectedGradingPeriodId)) { [weak self] in
            self?.assignmentGroupsDidUpdate()
        }

        assignmentGroups?.refresh()
    }

    private func assignmentGroupsDidUpdate() {
        guard let assignmentGroups else { return }
        if !assignmentGroups.requested || assignmentGroups.pending || !gradingPeriods.requested || gradingPeriods.pending { return }

        if !wasAssignmentGroupsUpdated, assignmentGroups.isEmpty {
            wasAssignmentGroupsUpdated = true
            assignmentGroups.refresh(force: true)
            return
        }

        var sections: [AssignmentListSection] = []
        let allAssignments: [Assignment] = assignmentGroups
            .compactMap { $0 }
            .sorted { $0.dueAtForSorting < $1.dueAtForSorting }
        let filteredAssignments = isTeacher
            ? filterAssignmentsTeacher(allAssignments)
            : filterAssignmentsStudent(allAssignments)

        switch selectedSortingOption {
        case .groupName, .assignmentGroup:
            for section in 0..<(assignmentGroups.sections?.count ?? 0) {
                if let assignmentGroup = assignmentGroups[IndexPath(row: 0, section: section)]?.assignmentGroup {
                    let assignments: [Assignment] = filteredAssignments.filter { $0.assignmentGroup == assignmentGroup }
                    if assignments.isNotEmpty {
                        sections.append(.init(
                            id: assignmentGroup.id,
                            title: assignmentGroup.name,
                            rows: assignments.map { row(for: $0) }
                        ))
                    }
                }
            }
        case .dueDate:
            let rightNow = Clock.now
            let overdue = filteredAssignments.filter { $0.dueAtOrCheckpointsDueAt ?? Date.distantFuture < rightNow }
            let upcoming = filteredAssignments.filter { $0.dueAtOrCheckpointsDueAt ?? Date.distantPast > rightNow }
            let undated = filteredAssignments.filter { $0.dueAtOrCheckpointsDueAt == nil }

            if overdue.isNotEmpty {
                sections.append(.init(
                    id: "overdue",
                    title: String(localized: "Overdue Assignments", bundle: .core),
                    rows: overdue.map { row(for: $0) }
                ))
            }
            if upcoming.isNotEmpty {
                sections.append(.init(
                    id: "upcoming",
                    title: String(localized: "Upcoming Assignments", bundle: .core),
                    rows: upcoming.map { row(for: $0) }
                ))
            }
            if undated.isNotEmpty {
                sections.append(.init(
                    id: "undated",
                    title: String(localized: "Undated Assignments", bundle: .core),
                    rows: undated.map { row(for: $0) }
                ))
            }
        case .assignmentType:
            let normal = filteredAssignments.filter { $0.quizID == nil && !$0.isLTIAssignment && !$0.isDiscussion }
            let discussions = filteredAssignments.filter { $0.isDiscussion }
            let quizzes = filteredAssignments.filter { $0.quizID != nil || $0.isQuizLTI }
            let lti = filteredAssignments.filter { $0.isLTIAssignment && !$0.isQuizLTI }

            if normal.isNotEmpty {
                sections.append(.init(
                    id: "normal",
                    title: String(localized: "Assignments", bundle: .core),
                    rows: normal.map { row(for: $0) }
                ))
            }
            if discussions.isNotEmpty {
                sections.append(.init(
                    id: "discussions",
                    title: String(localized: "Discussions", bundle: .core),
                    rows: discussions.map { row(for: $0) }
                ))
            }
            if quizzes.isNotEmpty {
                sections.append(.init(
                    id: "quizzes",
                    title: String(localized: "Quizzes", bundle: .core),
                    rows: quizzes.map { row(for: $0) }
                ))
            }
            if lti.isNotEmpty {
                sections.append(.init(
                    id: "lti",
                    title: String(localized: "LTI", bundle: .core),
                    rows: lti.map { row(for: $0) }
                ))
            }
        }

        self.sections = sections
        state = (sections.isEmpty ? .empty : .data)
    }

    private func filterAssignmentsStudent(_ assignments: [Assignment]) -> [Assignment] {
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

    private func row(for assignment: Assignment) -> AssignmentListSection.Row {
        if isTeacher {
            .teacher(.init(assignment: assignment))
        } else {
            .student(.init(assignment: assignment))
        }
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
            courseColor: Color(courseColor ?? Brand.shared.primary),
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
        guard let userDefaults else { return }

        if let savedStudentFilterOptionIds = userDefaults.assignmentListStudentFilterSettingsByCourseId?[courseID] {
            selectedFilterOptionsStudent = savedStudentFilterOptionIds.compactMap { id in
                AssignmentFilterOptionStudent.allCases.first { $0.id == id }
            }
        }

        if let savedTeacherFilterOptionId = userDefaults.assignmentListTeacherFilterSettingByCourseId?[courseID],
           let savedTeacherFilterOption = AssignmentFilterOptionsTeacher(rawValue: savedTeacherFilterOptionId) {
            selectedFilterOptionTeacher = savedTeacherFilterOption
        }

        if let savedStatusFilterOptionId = userDefaults.assignmentListTeacherStatusFilterSettingByCourseId?[courseID],
           let savedStatusFilterOption = AssignmentStatusFilterOptionsTeacher(rawValue: savedStatusFilterOptionId) {
            selectedStatusFilterOptionTeacher = savedStatusFilterOption
        }

        if let savedGroupByOptionId = userDefaults.assignmentListGroupBySettingByCourseId?[courseID],
           let savedGroupByOption = GroupingOptions(rawValue: savedGroupByOptionId) {
            selectedSortingOption = savedGroupByOption
        }
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

    init(state: InstUI.ScreenState, sections: [AssignmentListSection] = []) {
        self.env = .shared
        self.courseID = ""
        self.state = state
        self.sections = sections
        self.defaultGradingPeriodId = nil
        self.defaultSortingOption = AppEnvironment.shared.app == .teacher ? .assignmentType : .dueDate
        self.selectedSortingOption = AppEnvironment.shared.app == .teacher ? .assignmentType : .dueDate
        self.isTeacher = AppEnvironment.shared.app == .teacher
        self.sortingOptions = AppEnvironment.shared.app == .teacher ? GroupingOptions.teacherCases : GroupingOptions.studentCases
    }

#endif
}

extension AssignmentListScreenViewModel: Refreshable {

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
