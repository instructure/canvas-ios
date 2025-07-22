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

enum GradeInputType {
    case pointsTextField
    case percentageTextField
    case pointsDisplayOnly // for Complete/Incomplete
    case gradePicker // for GPA & Lettergrade
}

class SpeedGraderSubmissionGradesViewModel: ObservableObject {

    // MARK: - Outputs

    let state: InstUI.ScreenState

    // Grading inputs
    @Published private(set) var gradeState: GradeState = .empty
    @Published private(set) var gradeInputType: GradeInputType?
    @Published private(set) var isSaving: Bool = false
    let shouldShowSlider: Bool
    @Published var sliderValue: Double = 0
    @Published var isNoGradeButtonDisabled: Bool = false

    // Grade summary
    @Published private(set) var shouldShowGradeSummary: Bool = false
    @Published private(set) var pointsRowModel: PointsRowViewModel?
    @Published private(set) var latePenaltyRowModel: LatePenaltyRowViewModel?
    @Published private(set) var finalGradeRowModel: FinalGradeRowViewModel?

    // Error alert
    @Published var isShowingErrorAlert: Bool = false
    private(set) var errorAlertViewModel: ErrorAlertViewModel = .empty

    // MARK: - Private Properties

    private let assignment: Assignment
    private let gradeInteractor: GradeInteractor
    private var cancellables = Set<AnyCancellable>()
    private let mainScheduler: AnySchedulerOf<DispatchQueue>

    // MARK: - Init

    init(
        assignment: Assignment,
        submission: Submission,
        gradeInteractor: GradeInteractor,
        mainScheduler: AnySchedulerOf<DispatchQueue> = .main
    ) {
        self.assignment = assignment
        self.gradeInteractor = gradeInteractor
        self.mainScheduler = mainScheduler

        // On mobile we don't support Moderated Grading at the moment.
        // - It's multiple graders grading and then a moderator giving final grade.
        // - Course level feature, needs to be enabled before setting this on an assignment.
        // In that case we display a relevant empty panda.
        self.state = assignment.moderatedGrading ? .empty : .data

        self.shouldShowSlider = !assignment.useRubricForGrading
            && [.points, .percent].contains(assignment.gradingType)

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
                gradeState = newState
                gradeInputType = newState.gradeInputType
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

private extension GradeState {
    var gradeInputType: GradeInputType? {
        switch gradingType {
        case .percent:
            .percentageTextField
        case .points:
            .pointsTextField
        case .pass_fail:
            .pointsDisplayOnly
        case .gpa_scale, .letter_grade:
            .gradePicker
        case .not_graded:
            nil
        }
    }
}
