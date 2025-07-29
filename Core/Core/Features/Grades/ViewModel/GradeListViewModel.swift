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
import UIKit

public enum GradeArrangementOptions: String, CaseIterable {
    case dueDate
    case groupName
}

public final class GradeListViewModel: ObservableObject {
    typealias RefreshCompletion = () -> Void
    typealias IgnoreCache = Bool

    enum ViewState: Equatable {
        case initialLoading
        case data(GradeListData)
        case empty(GradeListData)
        case error
    }

    // MARK: - Dependencies

    private let interactor: GradeListInteractor

    // MARK: - Output
    @Published private(set) var courseName: String?
    @Published private(set) var courseColor: UIColor?
    @Published private(set) var totalGradeText: String?
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
    let didSelectGradingPeriod = PassthroughRelay<String?>()
    let selectedGroupByOption = CurrentValueRelay<GradeArrangementOptions>(.dueDate)
    var isParentApp: Bool {
        gradeFilterInteractor.isParentApp
    }

    // MARK: - Private properties
    private var subscriptions = Set<AnyCancellable>()
    private let env: AppEnvironment
    private var router: Router { env.router }
    private let gradeFilterInteractor: GradeFilterInteractor
    private let scheduler: AnySchedulerOf<DispatchQueue>
    private let triggerGradeRefresh = PassthroughRelay<(IgnoreCache, RefreshCompletion?)>()
    private var selectedGradingPeriod: String?

    // MARK: - Init

    public init(
        interactor: GradeListInteractor,
        gradeFilterInteractor: GradeFilterInteractor,
        env: AppEnvironment,
        scheduler: AnySchedulerOf<DispatchQueue> = .main,
    ) {
        self.interactor = interactor
        self.env = env
        self.gradeFilterInteractor = gradeFilterInteractor
        self.scheduler = scheduler

        isWhatIfScoreFlagEnabled = interactor.isWhatIfScoreFlagEnabled()

        pullToRefreshDidTrigger
            .sink { [weak self] in
                self?.loadBaseDataAndGrades(ignoreCache: true, completionBlock: $0)
            }
            .store(in: &subscriptions)

        didSelectGradingPeriod
            .sink { [weak self] newGradingPeriod in
                self?.selectedGradingPeriod = newGradingPeriod
                self?.triggerGradeRefresh.accept((true, nil))
            }
            .store(in: &subscriptions)

        $baseOnGradedAssignment
            .sink { [triggerGradeRefresh] _ in
                triggerGradeRefresh.accept((false, nil))
            }
            .store(in: &subscriptions)

        triggerGradeRefresh
            .receive(on: scheduler)
            .flatMap { [weak self] (ignoreCache, refreshCompletion) -> AnyPublisher<Void, Never> in
                guard let self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }

                // Changing the grading period fires an API request that takes time,
                // so we need to show a loading indicator.
                if refreshCompletion == nil, ignoreCache {
                    state = .initialLoading
                }

                return refreshGrades(ignoreCache: ignoreCache)
                    .map {
                        refreshCompletion?()
                    }
                    .eraseToAnyPublisher()
            }
            .sink()
            .store(in: &subscriptions)

        didSelectAssignment
            .receive(on: scheduler)
            .sink { [weak self] vc, assignment in
                self?.router.route(to: "/courses/\(interactor.courseID)/assignments/\(assignment.id)", from: vc, options: .detail)
            }
            .store(in: &subscriptions)

        loadSortPreferences()
        loadBaseDataAndGrades(ignoreCache: false, isInitialLoad: true)
    }

    private func loadBaseDataAndGrades(ignoreCache: Bool, isInitialLoad: Bool = false, completionBlock: (() -> Void)? = nil) {
        interactor
            .loadBaseData(ignoreCache: ignoreCache)
            .map { [weak self] gradingPeriodData in
                // Initial loading selects the currently active grading period
                if isInitialLoad {
                    self?.selectedGradingPeriod = gradingPeriodData.currentlyActiveGradingPeriodID
                }
            }
            .mapToVoid()
            .receive(on: scheduler)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.state = .error
                    completionBlock?()
                }
            } receiveValue: { [triggerGradeRefresh] in
                triggerGradeRefresh.accept((ignoreCache, completionBlock))
            }
            .store(in: &subscriptions)
    }

    private func refreshGrades(ignoreCache: Bool) -> AnyPublisher<Void, Never> {
        interactor.getGrades(
            arrangeBy: selectedGroupByOption.value,
            baseOnGradedAssignment: baseOnGradedAssignment,
            gradingPeriodID: selectedGradingPeriod,
            ignoreCache: ignoreCache
        )
        .receive(on: scheduler)
        .flatMap { [weak self] listData -> AnyPublisher<ViewState, Never> in
            guard let self else {
                return Empty(completeImmediately: true).eraseToAnyPublisher()
            }
            courseName = listData.courseName
            courseColor = listData.courseColor
            totalGradeText = listData.totalGradeText

            if listData.assignmentSections.count == 0 {
                return Just(ViewState.empty(listData)).eraseToAnyPublisher()
            } else {
                return Just(ViewState.data(listData)).eraseToAnyPublisher()
            }
        }
        .replaceError(with: .error)
        .receive(on: scheduler)
        .map { [weak self] in
            self?.state = $0
            return ()
        }
        .eraseToAnyPublisher()
    }

    private func loadSortPreferences() {
       guard let id = gradeFilterInteractor.selectedSortById,
             let option = GradeArrangementOptions(rawValue: id)
       else { return }

        selectedGroupByOption.accept(option)
    }

    func navigateToFilter(viewController: WeakViewController) {
        let gradeData: GradeListData? = {
            switch state {
            case .data(let gradeListData): return gradeListData
            case .empty(let gradeListData): return gradeListData
            default: return nil
            }
        }()

        guard let gradeData else { return }

        let isShowGradingPeriod = !gradeData.isGradingPeriodHidden
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: isShowGradingPeriod,
            initialGradingPeriodID: selectedGradingPeriod,
            courseName: courseName,
            selectedGradingPeriodPublisher: didSelectGradingPeriod,
            selectedSortByPublisher: selectedGroupByOption,
            gradingPeriods: gradeData.gradingPeriods,
            sortByOptions: GradeArrangementOptions.allCases
        )

        let filterView = GradeListAssembly.makeGradeFilterViewController(
            dependency: dependency,
            gradeFilterInteractor: gradeFilterInteractor,
            env: env
        )
        router.show(
            filterView,
            from: viewController,
            options: .modal(.automatic, isDismissable: false, embedInNav: true, addDoneButton: false, animated: true)
        )
    }
}
