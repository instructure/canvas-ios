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

public enum GradeArrangementOptions {
    case groupName
    case dueDate
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

    @Published private(set) var state: ViewState = .initialLoading
    @Published public var isWhatIfScoreOn = false
    @Published public var isWhatIfScoreEnabled = false
    public var courseID: String { interactor.courseID }

    // MARK: - Input

    let pullToRefreshDidTrigger = PassthroughRelay<RefreshCompletion?>()
    let didSelectAssignment = PassthroughRelay<(WeakViewController, Assignment)>()
    let confirmRevertAlertViewModel = ConfirmationAlertViewModel(
        title: String(localized: "Revert to Official Score?"),
        message: String(localized: "This will revert all your what-if scores in this course to the official score."),
        cancelButtonTitle: String(localized: "Cancel"),
        confirmButtonTitle: String(localized: "Revert"),
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

    // MARK: - Init

    public init(
        interactor: GradeListInteractor,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor

        let triggerRefresh = PassthroughRelay<(IgnoreCache, RefreshCompletion?)>()

        isWhatIfScoreEnabled = interactor.isWhatIfScoreEnabled()

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

        selectedGroupByOption
            .sink { _ in
                triggerRefresh.accept((false, nil))
            }
            .store(in: &subscriptions)

        $baseOnGradedAssignment
            .sink { _ in
                triggerRefresh.accept((false, nil))
            }
            .store(in: &subscriptions)

        triggerRefresh.prepend((false, nil))
            .receive(on: scheduler)
            .flatMapLatest { [unowned self] params in
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
                .map { [unowned self] listData -> ViewState in
                    lastKnownDataState = listData

                    if listData.assignmentSections.count == 0 {
                        return ViewState.empty(listData)
                    } else {
                        return ViewState.data(listData)
                    }
                }
                .replaceError(with: .error)
                .map {
                    refreshCompletion?()
                    return $0
                }
                .first()
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
}
