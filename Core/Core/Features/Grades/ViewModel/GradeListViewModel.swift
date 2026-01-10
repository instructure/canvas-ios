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

import UIKit
import Observation

public enum GradeArrangementOptions: String, CaseIterable {
    case dueDate
    case groupName
}

@Observable
public final class GradeListViewModel {
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
    private(set) var courseName: String?
    private(set) var courseColor: UIColor?
    private(set) var totalGradeText: String?
    private(set) var state: ViewState = .initialLoading
    private(set) var task: Task<Void, Never>?
    public var isWhatIfScoreModeOn = false
    public var isWhatIfScoreFlagEnabled = false
    public var selectedAssignmentId: String?
    var courseID: String { interactor.courseID }
    var isParentApp: Bool { gradeFilterInteractor.isParentApp }

    // MARK: - Input
    let confirmRevertAlertViewModel = ConfirmationAlertViewModel(
        title: String(localized: "Revert to Official Score?", bundle: .core),
        message: String(localized: "This will revert all your what-if scores in this course to the official score.", bundle: .core),
        cancelButtonTitle: String(localized: "Cancel", bundle: .core),
        confirmButtonTitle: String(localized: "Revert", bundle: .core),
        isDestructive: false
    )

    // MARK: - Input / Output
    var baseOnGradedAssignment = true {
        didSet {
            task = Task { await refreshGrades(ignoreCache: false) }
        }
    }
    var isShowingRevertDialog = false
    var selectedGroupByOption: GradeArrangementOptions = .dueDate

    // MARK: - Private properties
    private let env: AppEnvironment
    private var router: Router { env.router }
    private let gradeFilterInteractor: GradeFilterInteractor
    private var selectedGradingPeriod: String?

    // MARK: - Init

    public init(
        interactor: GradeListInteractor,
        gradeFilterInteractor: GradeFilterInteractor,
        env: AppEnvironment,
    ) {
        self.interactor = interactor
        self.env = env
        self.gradeFilterInteractor = gradeFilterInteractor

        isWhatIfScoreFlagEnabled = interactor.isWhatIfScoreFlagEnabled()

        loadSortPreferences()

        task = Task {
            await loadBaseDataAndGrades(ignoreCache: false, isInitialLoad: true)
        }
    }

    func selectGradingPeriod(id: String?) {
        selectedGradingPeriod = id
        state = .initialLoading

        task = Task {
            await refreshGrades(ignoreCache: true)
        }
    }

    func selectAssignment(url: URL?, id: String, controller: WeakViewController) {
        guard let url else { return }
        selectedAssignmentId = id
        env.router.route(to: url, from: controller, options: .detail)
    }

    func refresh() async {
        await loadBaseDataAndGrades(ignoreCache: true)
    }

    private func loadBaseDataAndGrades(ignoreCache: Bool, isInitialLoad: Bool = false) async {
        do {
            let gradingPeriodData = try await interactor.loadBaseData(ignoreCache: ignoreCache)

            // Initial loading selects the currently active grading period
            if isInitialLoad {
                state = .initialLoading

                selectedGradingPeriod = gradingPeriodData.currentlyActiveGradingPeriodID
            }

            await refreshGrades(ignoreCache: ignoreCache)
        } catch {
            state = .error
        }
    }

    private func refreshGrades(ignoreCache: Bool) async {
        do {
            let listData = try await interactor.getGrades(
                arrangeBy: selectedGroupByOption,
                baseOnGradedAssignment: baseOnGradedAssignment,
                gradingPeriodID: selectedGradingPeriod,
                ignoreCache: ignoreCache
            )

            courseName = listData.courseName
            courseColor = listData.courseColor
            totalGradeText = listData.totalGradeText

            state = listData.assignmentSections.count == 0 ? .empty(listData) : .data(listData)
        } catch {
            state = .error
        }
    }

    private func loadSortPreferences() {
        guard let id = gradeFilterInteractor.selectedSortById,
              let option = GradeArrangementOptions(rawValue: id)
        else { return }

        selectedGroupByOption = option
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
            selectGradingPeriod: { self.selectGradingPeriod(id: $0) },
            selectSortByOption: { self.selectedGroupByOption = $0 },
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
