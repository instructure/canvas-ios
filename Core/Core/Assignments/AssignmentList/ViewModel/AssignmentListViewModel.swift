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
import CombineExt
import CombineSchedulers
import Foundation

public enum Order: String {
    case dueAscending
    case dueDescending
}

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

public final class AssignmentListViewModel: ObservableObject {
    typealias RefreshCompletion = () -> Void
    typealias IgnoreCache = Bool

    public enum ViewModelState: Equatable {
        case loading
        case data(AssignmentListData)
        case empty(AssignmentListData)
        case error
    }

    // MARK: - Dependencies

    private let interactor: AssignmentListInteractor

    @Published public private(set) var state: ViewModelState = .loading
    @Published public private(set) var courseColor: UIColor?
    @Published public private(set) var courseName: String?
    @Published public private(set) var shouldShowFilterButton = false
    @Published public private(set) var defaultDetailViewRoute = "/empty"
    public private(set) lazy var gradingPeriods: Store<LocalUseCase<GradingPeriod>> = {
        let scope: Scope = .where(
            #keyPath(GradingPeriod.courseID),
            equals: courseID,
            orderBy: #keyPath(GradingPeriod.startDate)
        )
        return env.subscribe(LocalUseCase(scope: scope)) { [weak self] in
            self?.gradingPeriodsDidUpdate()
        }
    }()

    public var selectedOrder: Order?

    private let env = AppEnvironment.shared
    var courseID: String { interactor.courseID }

    // MARK: - Input
    let pullToRefreshDidTrigger = PassthroughRelay<RefreshCompletion?>()
    let didSelectAssignment = PassthroughRelay<(WeakViewController, Assignment)>()
    let selectedGradingPeriod = PassthroughRelay<String?>()
    let selectedGroupByOption = CurrentValueRelay<AssignmentArrangementOptions>(.dueDate)
    var isParentApp: Bool {
        assignmentFilterInteractor.isParentApp
    }

    // MARK: - Private properties
    private var lastKnownDataState: AssignmentListData? {
        didSet {
            if !isInitialGradingPeriodSet {
                isInitialGradingPeriodSet = true
                state = .loading
                let id = getSelectedGradingPeriodId(
                    currentGradingPeriodID: lastKnownDataState?.currentGradingPeriodID,
                    gradingPeriods: lastKnownDataState?.gradingPeriods ?? []
                )
                selectedGradingPeriod.accept(id)
            }
        }
    }
    private var subscriptions = Set<AnyCancellable>()
    private let router: Router
    private let assignmentFilterInteractor: AssignmentFilterInteractor
    private var isInitialGradingPeriodSet = false

    private lazy var assignmentGroups = env.subscribe(GetAssignmentsByGroup(courseID: courseID)) { [weak self] in
        self?.assignmentGroupsDidUpdate()
    }
    private lazy var course = env.subscribe(GetCourse(courseID: courseID)) { [weak self] in
        self?.courseDidUpdate()
    }

    /** This is required for the router to help decide if the hybrid discussion details or the native one should be launched. */
    private lazy var featureFlags = env.subscribe(GetEnabledFeatureFlags(context: .course(courseID)))

    public init(
        interactor: AssignmentListInteractor,
        assignmentFilterInteractor: AssignmentFilterInteractor,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.router = router
        self.assignmentFilterInteractor = assignmentFilterInteractor
        let triggerRefresh = PassthroughRelay<(IgnoreCache, RefreshCompletion?)>()

        pullToRefreshDidTrigger
            .sink {
                triggerRefresh.accept((true, $0))
            }
            .store(in: &subscriptions)

        selectedGradingPeriod
            .sink {
                interactor.updateGradingPeriod(id: $0)
                triggerRefresh.accept((true, nil))
            }
            .store(in: &subscriptions)

        triggerRefresh.prepend((false, nil))
            .receive(on: scheduler)
            .flatMapLatest { [weak self] params -> AnyPublisher<ViewModelState, Never> in
                guard let self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                let ignoreCache = params.0
                let refreshCompletion = params.1

                // Changing the grading period fires an API request that takes time,
                // so we need to show a loading indicator.
                if lastKnownDataState != nil, refreshCompletion == nil, ignoreCache {
                    // Empty list of assignments so can't get the normal size of scrollView
                    state = .data(.init())
                }

                return interactor.getAssignments(
                    arrangeBy: selectedGroupByOption.value,
                    ignoreCache: ignoreCache,
                    shouldUpdateGradingPeriod: false
                )
                .first()
                .receive(on: scheduler)
                .flatMap { [weak self] listData -> AnyPublisher<ViewModelState, Never> in
                    guard let self else {
                        return Empty(completeImmediately: true).eraseToAnyPublisher()
                    }
                    lastKnownDataState = listData
                    courseName = listData.courseName
                    courseColor = listData.courseColor
                    if listData.assignmentSections.count == 0 {
                        return Just(ViewModelState.empty(listData)).eraseToAnyPublisher()
                    } else {
                        return Just(ViewModelState.data(listData)).eraseToAnyPublisher()
                    }
                }
                .replaceError(with: .error)
                .map {
                    refreshCompletion?()
                    return $0
                }
                .first()
                .eraseToAnyPublisher()
            }
            .receive(on: scheduler)
            .assign(to: &$state)

        didSelectAssignment
            .receive(on: scheduler)
            .sink { vc, assignment in
                router.route(to: "/courses/\(interactor.courseID)/assignments/\(assignment.id)", from: vc, options: .detail)
            }
            .store(in: &subscriptions)

        loadSortPreferences()
    }

   private func loadSortPreferences() {
        let selectedSortById = assignmentFilterInteractor.selectedSortById
        let selectedSortByOption = AssignmentArrangementOptions(rawValue: selectedSortById ?? 0) ?? .dueDate
        selectedGroupByOption.accept(selectedSortByOption)
    }

    private func getSelectedGradingPeriodId(
        currentGradingPeriodID: String?,
        gradingPeriods: [GradingPeriod]
    ) -> String? {
        let currentId = assignmentFilterInteractor.selectedGradingId
        guard !gradingPeriods.isEmpty else {
            assignmentFilterInteractor.saveSelectedGradingPeriod(id: currentGradingPeriodID)
            return currentGradingPeriodID
        }

        if let currentId {
            if currentId == assignmentFilterInteractor.gradingShowAllId {
                return nil
            } else if gradingPeriods.contains(where: { $0.id == currentId }) {
                return currentId
            } else {
                assignmentFilterInteractor.saveSelectedGradingPeriod(id: gradingPeriods.first?.id)
                assignmentFilterInteractor.saveSortByOption(type: .dueDate)
                return gradingPeriods.first?.id
            }
        }
        assignmentFilterInteractor.saveSelectedGradingPeriod(id: currentGradingPeriodID)
        return currentGradingPeriodID
    }

    func navigateToFilter(viewController: WeakViewController) {
        let isShowGradingPeriod = !(lastKnownDataState?.isGradingPeriodHidden ?? false)
        let dependency = AssignmentFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: isShowGradingPeriod,
            courseName: courseName,
            selectedGradingPeriodPublisher: selectedGradingPeriod,
            selectedSortByPublisher: selectedGroupByOption,
            gradingPeriods: lastKnownDataState?.gradingPeriods,
            sortByOptions: AssignmentArrangementOptions.allCases
        )

        let filterView = AssignmentListAssembly.makeAssignmentFilterViewController(
            dependency: dependency,
            assignmentFilterInteractor: assignmentFilterInteractor
        )
        router.show(
            filterView,
            from: viewController,
            options: .modal(.automatic, isDismissable: false, embedInNav: true, addDoneButton: false, animated: true)
        )
    }

    public func viewDidAppear() {
        gradingPeriods.refresh()
        course.refresh()
        assignmentGroups.refresh()
    }

    private func assignmentGroupsDidUpdate() {
        if !assignmentGroups.requested || assignmentGroups.pending { return }

        var assignmentGroups: [AssignmentGroupViewModel] = []

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

    private func gradingPeriodsDidUpdate() {
        if gradingPeriods.requested, gradingPeriods.pending { return }
        shouldShowFilterButton = gradingPeriods.all.count > 1
    }
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
