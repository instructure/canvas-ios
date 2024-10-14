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

public final class GradeListViewModel: ObservableObject {
    typealias RefreshCompletion = () -> Void
    typealias IgnoreCache = Bool

    // MARK: - Dependencies

    private let interactor: GradeListInteractor

    // MARK: - Output
    @Published private(set) var gradeListUIModel: GradeListUIModel = .init()
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
    let selectedGradingPeriod = PassthroughRelay<String?>()
    let selectedGroupByOption = CurrentValueRelay<GradeArrangementOptions>(.dueDate)
    var isParentApp: Bool {
        gradeFilterInteractor.isParentApp
    }

    // MARK: - Private properties
    private var lastKnownDataState: GradeListData?
    private var subscriptions = Set<AnyCancellable>()
    private let router: Router
    private let gradeFilterInteractor: GradeFilterInteractor
    private var isInitialGradingPeriodSet = false
    // MARK: - Init

    public init(
        interactor: GradeListInteractor,
        gradeFilterInteractor: GradeFilterInteractor,
        router: Router,
        scheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.interactor = interactor
        self.router = router
        self.gradeFilterInteractor = gradeFilterInteractor
        let triggerRefresh = PassthroughRelay<(IgnoreCache, RefreshCompletion?)>()

        isWhatIfScoreFlagEnabled = interactor.isWhatIfScoreFlagEnabled()

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

        $baseOnGradedAssignment
            .sink { _ in
                triggerRefresh.accept((false, nil))
            }
            .store(in: &subscriptions)

        triggerRefresh.prepend((false, nil))
            .receive(on: scheduler)
            .flatMapLatest { [weak self] params -> AnyPublisher<GradeListUIModel, Never> in
                guard let self else {
                    return Empty(completeImmediately: true).eraseToAnyPublisher()
                }
                let ignoreCache = params.0
                let refreshCompletion = params.1

                // Changing the grading period fires an API request that takes time,
                // so we need to show a loading indicator.
                if lastKnownDataState != nil, refreshCompletion == nil, ignoreCache {
                    gradeListUIModel.isLoaderVisible = true
                    gradeListUIModel.state = .data(.init())
                }

                return interactor.getGrades(
                    arrangeBy: selectedGroupByOption.value,
                    baseOnGradedAssignment: baseOnGradedAssignment,
                    ignoreCache: ignoreCache,
                    shouldUpdateGradingPeriod: false
                )
                .first()
                .map { [weak self] listData in
                    self?.getAssignmentsForSelectedGradingPeriod(grades: listData)
                    return listData
                }
                .receive(on: scheduler)
                .flatMap { [weak self] listData -> AnyPublisher<GradeListUIModel, Never> in
                    guard let self else {
                        return Empty(completeImmediately: true).eraseToAnyPublisher()
                    }
                    var model = GradeListUIModel()
                    model.gradeHeaderIsVisible = isInitialGradingPeriodSet
                    lastKnownDataState = listData
                    model.courseName = listData.courseName
                    model.courseColor = listData.courseColor
                    model.totalGradeText = listData.totalGradeText
                    model.isLoaderVisible = false
                    if listData.assignmentSections.count == 0 {
                        model.state = .empty(listData)
                    } else {
                        model.state = .data(listData)
                    }
                    return Just(model).eraseToAnyPublisher()
                }
                .replaceError(with: .init(state: .error))
                .map {
                    refreshCompletion?()
                    return $0
                }
                .first()
                .eraseToAnyPublisher()
            }
            .receive(on: scheduler)
            .assign(to: &$gradeListUIModel)

        didSelectAssignment
            .receive(on: scheduler)
            .sink { vc, assignment in
                router.route(to: "/courses/\(interactor.courseID)/assignments/\(assignment.id)", from: vc, options: .detail)
            }
            .store(in: &subscriptions)

        loadSortPreferences()
    }

   private func loadSortPreferences() {
        let selectedSortById = gradeFilterInteractor.selectedSortById
        let selectedSortByOption = GradeArrangementOptions(rawValue: selectedSortById ?? 0) ?? .dueDate
        selectedGroupByOption.accept(selectedSortByOption)
    }

   private func getAssignmentsForSelectedGradingPeriod(grades: GradeListData) {
        if !isInitialGradingPeriodSet {
            isInitialGradingPeriodSet = true
            gradeListUIModel.gradeHeaderIsVisible = false
            gradeListUIModel.state = .initialLoading
            let id = getSelectedGradingPeriodId(
                currentGradingPeriodID: grades.currentGradingPeriodID,
                gradingPeriods: grades.gradingPeriods
            )
            selectedGradingPeriod.accept(id)
        }
    }

    private func getSelectedGradingPeriodId(
        currentGradingPeriodID: String?,
        gradingPeriods: [GradingPeriod]
    ) -> String? {
        let currentId = gradeFilterInteractor.selectedGradingId
        guard !gradingPeriods.isEmpty else {
            gradeFilterInteractor.saveSelectedGradingPeriod(id: currentGradingPeriodID)
            return currentGradingPeriodID
        }

        if let currentId {
            if currentId == gradeFilterInteractor.gradingShowAllId {
                return nil
            } else if gradingPeriods.contains(where: { $0.id == currentId }) {
                return currentId
            } else {
                gradeFilterInteractor.saveSelectedGradingPeriod(id: gradingPeriods.first?.id)
                gradeFilterInteractor.saveSortByOption(type: .dueDate)
                return gradingPeriods.first?.id
            }
        }
        gradeFilterInteractor.saveSelectedGradingPeriod(id: currentGradingPeriodID)
        return currentGradingPeriodID
    }

    func navigateToFilter(viewController: WeakViewController) {
        let isShowGradingPeriod = !(lastKnownDataState?.isGradingPeriodHidden ?? false)
        let dependency = GradeFilterViewModel.Dependency(
            router: router,
            isShowGradingPeriod: isShowGradingPeriod,
            courseName: lastKnownDataState?.courseName,
            selectedGradingPeriodPublisher: selectedGradingPeriod,
            selectedSortByPublisher: selectedGroupByOption,
            gradingPeriods: lastKnownDataState?.gradingPeriods,
            sortByOptions: GradeArrangementOptions.allCases
        )

        let filterView = GradListAssembly.makeGradeFilterViewController(
            dependency: dependency,
            gradeFilterInteractor: gradeFilterInteractor
        )
        router.show(
            filterView,
            from: viewController,
            options: .modal(.automatic, isDismissable: false, embedInNav: true, addDoneButton: false, animated: true)
        )
    }
}
