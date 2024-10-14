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

public enum AssignmentArrangementOptions: Int, CaseIterable {
    case groupName = 1
    case dueDate = 2

    var title: String {
        switch self {
        case .groupName:
            return String(localized: "Group", bundle: .core)
        case .dueDate:
            return String(localized: "Due Date", bundle: .core)
        }
    }
}

public struct AssignmentDateGroup {
    public let name: String
    public let assignments: [Assignment]
}

public class AssignmentListViewModel: ObservableObject {
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

    // MARK: - Variables

    public var selectedSortingOption: AssignmentArrangementOptions = .groupName
    public var selectedGradingPeriod: GradingPeriod?
    private var sortingOptions = AssignmentArrangementOptions.allCases
    private let env = AppEnvironment.shared
    let courseID: String

    public private(set) lazy var gradingPeriods: Store<LocalUseCase<GradingPeriod>> = {
        let scope: Scope = .where(
            #keyPath(GradingPeriod.courseID),
            equals: courseID,
            orderBy: #keyPath(GradingPeriod.startDate)
        )
        return env.subscribe(LocalUseCase(scope: scope)) { }
    }()

    private lazy var assignmentGroups = env.subscribe(GetAssignmentsByGroup(courseID: courseID)) { [weak self] in
        self?.assignmentGroupsDidUpdate()
    }
    private lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.courseDidUpdate()
    }

    /** This is required for the router to help decide if the hybrid discussion details or the native one should be launched. */
    private lazy var featureFlags = env.subscribe(GetEnabledFeatureFlags(context: .course(courseID)))

    // MARK: - Init
    public init(context: Context) {
        self.courseID = context.id

        featureFlags.refresh()
    }

    // MARK: - Functions

    public func gradingPeriodFilterCleared() {
        filterOptionSelected(nil)
    }

    public func filterOptionSelected(_ gradingPeriod: GradingPeriod?, _ sortingOption: AssignmentArrangementOptions? = nil) {
        selectedGradingPeriod = gradingPeriod
        selectedSortingOption = sortingOption ?? .groupName

        assignmentGroups = env.subscribe(GetAssignmentsByGroup(courseID: courseID, gradingPeriodID: gradingPeriod?.id)) { [weak self] in
            self?.assignmentGroupsDidUpdate()
        }
        assignmentGroups.refresh()
    }

    public func viewDidAppear() {
        gradingPeriods.refresh()
        course.refresh()
        assignmentGroups.refresh(force: true)
    }

    private func assignmentGroupsDidUpdate() {
        if !assignmentGroups.requested || assignmentGroups.pending { return }

        isShowingGradingPeriods = assignmentGroups.count > 1
        var assignmentGroups: [AssignmentGroupViewModel] = []

        switch selectedSortingOption {
        case .groupName:
            for section in 0..<(self.assignmentGroups.sections?.count ?? 0) {
                if let group = self.assignmentGroups[IndexPath(row: 0, section: section)]?.assignmentGroup {
                    let assignments: [Assignment] = self.assignmentGroups.filter { $0.assignmentGroup == group }
                    assignmentGroups.append(AssignmentGroupViewModel(
                        assignmentGroup: group,
                        assignments: assignments,
                        courseColor: courseColor
                    ))
                }
            }
        case .dueDate:
            let all = self.assignmentGroups.compactMap { $0 }
            let missed = all.filter { $0.dueAt ?? Date.distantFuture < Date.now }
            if !missed.isEmpty {
                let missedGroup = AssignmentDateGroup(name: "Overdue", assignments: missed)
                assignmentGroups.append(AssignmentGroupViewModel(assignmentDateGroup: missedGroup, courseColor: courseColor))
            }
            let upcoming = all.filter { $0.dueAt ?? Date.distantFuture > Date.now }
            if !upcoming.isEmpty {
                let upcomingGroup = AssignmentDateGroup(name: "Upcoming", assignments: upcoming)
                assignmentGroups.append(AssignmentGroupViewModel(assignmentDateGroup: upcomingGroup, courseColor: courseColor))
            }
        }

        state = (assignmentGroups.isEmpty ? .empty : .data(assignmentGroups))
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
            currentGradingPeriod: selectedGradingPeriod,
            sortingOptions: sortingOptions,
            currentSortingOption: selectedSortingOption,
            completion: { [weak self] filterOptions in
                self?.filterOptionSelected(filterOptions.gradingPeriod, filterOptions.sortingOption)
                self?.env.router.dismiss(weakVC)
            })
        let controller = CoreHostingController(AssignmentFilterScreen(viewModel: viewModel))
        weakVC.setValue(controller)
        env.router.show(
            controller,
            from: viewController,
            options: .modal(
                .automatic,
                isDismissable: false,
                embedInNav: true,
                addDoneButton: false,
                animated: true
            )
        )
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
