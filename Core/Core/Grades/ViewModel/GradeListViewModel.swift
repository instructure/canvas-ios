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

import Combine
import CombineExt
import CombineSchedulers
import Foundation

public enum GradeArrangementOptions: CaseIterable {
    case groupName
    case dueDate

    var title: String {
        switch self {
        case .groupName:
            return String(localized: "Group", bundle: .core)
        case .dueDate:
            return String(localized: "Due Date", bundle: .core)
        }
    }
}

public final class GradeListViewModel: ObservableObject {
    typealias RefreshCompletion = () -> Void
    typealias IgnoreCache = Bool

    enum ViewState: Equatable {
        case initialLoading
        case refreshing(GradeListData)
        case data(GradeListData)
        case empty(GradeListData)
        case error
    }

    // MARK: - Dependencies

    private let interactor: GradeListInteractor

    // MARK: - Output
    @Published public var courseName: String?
    @Published private(set) var gradeHeaderIsVisible = false
    @Published private(set) var state: ViewState = .initialLoading
    @Published public var isWhatIfScoreModeOn = false
    @Published public var isWhatIfScoreFlagEnabled = false
    public var courseID: String { interactor.courseID }

    // MARK: - Input

    let pullToRefreshDidTrigger = PassthroughRelay<RefreshCompletion?>()
    let didSelectAssignment = PassthroughRelay<(WeakViewController, Assignment)>()
    let confirmRevertAlertViewModel = ConfirmationAlertViewModel(
        title: String(localized: "Revert to Official Score?", bundle: .core),
        message: String(localized: "This will revert all your what-if scores in this course to the official score.", bundle: .core),
        cancelButtonTitle: String(localized: "Cancel", bundle: .core),
        confirmButtonTitle: String(localized: "Revert", bundle: .core),
        isDestructive: false
    )

    // MARK: - Input / Output

    @Published var baseOnGradedAssignment = true
    @Published var isShowingRevertDialog = false
    let selectedGradingPeriod = PassthroughRelay<GradingPeriod?>()
    let selectedGroupByOption = CurrentValueRelay<GradeArrangementOptions>(.groupName)

    // MARK: - Private properties

    private var lastKnownDataState: GradeListData?
    private var subscriptions = Set<AnyCancellable>()
    private let router: Router

    // MARK: - Init

    public init(
        interactor: GradeListInteractor,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.router = router
        let triggerRefresh = PassthroughRelay<(IgnoreCache, RefreshCompletion?)>()

        isWhatIfScoreFlagEnabled = interactor.isWhatIfScoreFlagEnabled()

        pullToRefreshDidTrigger
            .sink {
                triggerRefresh.accept((true, $0))
            }
            .store(in: &subscriptions)

        selectedGradingPeriod
            .sink {
                interactor.updateGradingPeriod(id: $0?.id)
                triggerRefresh.accept((true, nil))
            }
            .store(in: &subscriptions)

        $baseOnGradedAssignment
            .sink { _ in
                triggerRefresh.accept((false, nil))
            }
            .store(in: &subscriptions)

        triggerRefresh.prepend((false, nil))
            .receive(on: scheduler)
            .flatMapLatest { [weak self] params -> AnyPublisher<ViewState, Never> in
                guard let self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                let ignoreCache = params.0
                let refreshCompletion = params.1

                // Changing the grading period fires an API request that takes time,
                // so we need to show a loading indicator.
                if let lastKnownDataState, refreshCompletion == nil, ignoreCache {
                    state = .refreshing(lastKnownDataState)
                }

                return interactor.getGrades(
                    arrangeBy: selectedGroupByOption.value,
                    baseOnGradedAssignment: baseOnGradedAssignment,
                    ignoreCache: ignoreCache
                )
                .first()
                .receive(on: scheduler)
                .flatMap { [weak self] listData -> AnyPublisher<ViewState, Never> in
                    guard let self else {
                        return Empty(completeImmediately: true).eraseToAnyPublisher()
                    }
                    lastKnownDataState = listData
                    courseName = listData.courseName
                    if listData.assignmentSections.count == 0 {
                        return Just(ViewState.empty(listData)).eraseToAnyPublisher()
                    } else {
                        self.gradeHeaderIsVisible = true
                        return Just(ViewState.data(listData)).eraseToAnyPublisher()
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
    }

    func navigateToFilter(viewController: WeakViewController) {
        let isShowGradingPeriod = !(lastKnownDataState?.isGradingPeriodHidden ?? false)
        let dependency = GradeFilterViewModel.Dependency(
            router: router, 
            isShowGradingPeriod: isShowGradingPeriod,
            courseName: courseName,
            selectedGradingPeriodPublisher: selectedGradingPeriod,
            selectedSortByPublisher: selectedGroupByOption,
            gradingPeriods: lastKnownDataState?.gradingPeriods,
            selectedGradingPeriod: lastKnownDataState?.currentGradingPeriod,
            selectedSortBy: selectedGroupByOption.value,
            sortByOptions: GradeArrangementOptions.allCases
        )

        let filterView = GradListAssembly.makeGradeFilterViewController(dependency: dependency)
        router.show(
            filterView,
            from: viewController,
            options: .modal(.automatic, isDismissable: false, embedInNav: true, addDoneButton: false, animated: true)
        )
    }
}
