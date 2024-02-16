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
    typealias RefreshCompletion = (() -> Void)?

    enum ViewState: Equatable {
        case loading
        case data(GradeListData)
        case empty(GradeListData)
        case error
    }

    // MARK: - Dependencies

    private let interactor: GradeListInteractor

    // MARK: - Output

    @Published private(set) var state: ViewState = .loading
    public var courseID: String { interactor.courseID }

    // MARK: - Input

    let selectedGradingPeriod = PassthroughRelay<GradingPeriod?>()
    let selectedGroupByOption = CurrentValueRelay<GradeArrangementOptions>(.groupName)
    let pullToRefreshDidTrigger = PassthroughRelay<(() -> Void)?>()
    let didSelectAssignment = PassthroughRelay<(WeakViewController, Assignment)>()

    // MARK: - Private properties

    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Init

    public init(
        interactor: GradeListInteractor,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor

        let triggerRefresh = PassthroughRelay<(Bool, RefreshCompletion)>()

        pullToRefreshDidTrigger
            .sink {
                triggerRefresh.accept((true, $0))
            }
            .store(in: &subscriptions)

        selectedGroupByOption
            .sink { _ in
                triggerRefresh.accept((false, nil))
            }
            .store(in: &subscriptions)

        selectedGradingPeriod
            .sink {
                interactor.updateGradingPeriod(id: $0?.id)
                triggerRefresh.accept((true, nil))
            }
            .store(in: &subscriptions)

        triggerRefresh
            .prepend((false, nil))
            .flatMap { [unowned selectedGroupByOption] ignoreCache, refreshCompletion in
                interactor.getGrades(
                    arrangeBy: selectedGroupByOption.value,
                    ignoreCache: ignoreCache
                )
                .map { listData -> ViewState in
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
