//
// This file is part of Canvas.
// Copyright (C) 2025-present  Instructure, Inc.
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
import Core
import CoreData

class SpeedGraderSubmissionGradesViewModel: ObservableObject {

    // MARK: - Outputs

    @Published var sliderValue: Double = 0
    @Published var isShowingErrorAlert = false
    @Published var isNoGradeButtonDisabled = false
    @Published private(set) var state = GradeState.empty
    @Published private(set) var shouldShowGradeSummary = false
    @Published private(set) var pointsRowModel: PointsRowViewModel?
    @Published private(set) var latePenaltyRowModel: LatePenaltyRowViewModel?
    @Published private(set) var finalGradeRowModel: FinalGradeRowViewModel?
    @Published private(set) var isSaving = false
    @Published private(set) var errorAlertViewModel = ErrorAlertViewModel(
        title: String(localized: "Error", bundle: .teacher),
        message: "",
        buttonTitle: String(localized: "OK", bundle: .teacher)
    )

    // MARK: - Private Properties

    private let gradeInteractor: GradeInteractor
    private var cancellables = Set<AnyCancellable>()
    private let mainScheduler: AnySchedulerOf<DispatchQueue>

    init(
        assignment: Assignment,
        submission: Submission,
        gradeInteractor: GradeInteractor,
        mainScheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.gradeInteractor = gradeInteractor
        self.mainScheduler = mainScheduler

        observeGradeStateChanges()
    }

    // MARK: - User Actions

    func removeGrade() {
        saveGrade(grade: "")
    }

    func excuseStudent() {
        saveGrade(excused: true)
    }

    func setGrade(_ grade: String) {
        saveGrade(grade: grade)
    }

    func setPointsGrade(_ points: Double) {
        saveGrade(grade: String(points))
    }

    func setPercentGrade(_ percent: Double) {
        let percentValue = "\(round(percent))%"
        saveGrade(grade: percentValue)
    }

    func setPassFailGrade(complete: Bool) {
        saveGrade(grade: complete ? "complete" : "incomplete")
    }

    // MARK: - Private Methods

    private func observeGradeStateChanges() {
        gradeInteractor.gradeState
            .sink { [weak self] newState in
                guard let self else { return }
                state = newState
                sliderValue = newState.score
                isNoGradeButtonDisabled = (!newState.isGraded && !newState.isExcused)
                shouldShowGradeSummary = (!newState.isExcused && newState.gradingType != .not_graded)
                pointsRowModel = newState.pointsRowModel
                latePenaltyRowModel = newState.latePenaltyRowModel
                finalGradeRowModel = newState.finalGradeRowModel
            }
            .store(in: &cancellables)
    }

    private func saveGrade(excused: Bool? = nil, grade: String? = nil) {
        isSaving = true

        gradeInteractor.saveGrade(excused: excused, grade: grade)
            .receive(on: mainScheduler)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isSaving = false
                    if case .failure(let error) = completion {
                        self?.showError(error)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    private func showError(_ error: Error) {
        errorAlertViewModel = ErrorAlertViewModel(
            title: errorAlertViewModel.title,
            message: error.localizedDescription,
            buttonTitle: errorAlertViewModel.buttonTitle
        )
        isShowingErrorAlert = true
    }
}

// MARK: - GradeState Extension

extension GradeState {

    var pointsRowModel: PointsRowViewModel? {
        if gradingType == .points, !hasLateDeduction {
            return nil
        }
        return PointsRowViewModel(
            currentPoints: originalScoreWithoutMetric,
            maxPointsWithUnit: pointsPossibleText
        )
    }

    var latePenaltyRowModel: LatePenaltyRowViewModel? {
        if hasLateDeduction {
            return LatePenaltyRowViewModel(penaltyText: pointsDeductedText)
        } else {
            return nil
        }
    }

    var finalGradeRowModel: FinalGradeRowViewModel {
        let suffix: FinalGradeRowViewModel.SuffixType

        switch gradingType {
        case .percent:
            suffix = .percentage
        case .pass_fail, .letter_grade, .gpa_scale, .not_graded:
            suffix = .none
        case .points:
            suffix = .maxGradeWithUnit(pointsPossibleText)
        }

        return FinalGradeRowViewModel(
            currentGradeText: finalGradeWithoutMetric,
            suffixType: suffix
        )
    }
}
