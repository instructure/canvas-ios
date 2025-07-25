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
    case statusDisplayOnly // for Not Graded
}

class SpeedGraderSubmissionGradesViewModel: ObservableObject {

    // MARK: - Outputs

    let state: InstUI.ScreenState

    // Grading inputs
    @Published private(set) var gradeState: GradeState
    @Published private(set) var gradeInputType: GradeInputType?
    let isSavingGrade = CurrentValueSubject<Bool, Never>(false)
    let shouldShowPointsInput: Bool
    let shouldShowSlider: Bool
    let shouldShowSelector: Bool
    @Published var sliderValue: Double = 0
    @Published var isNoGradeButtonDisabled: Bool = false
    let selectGradeOption = CurrentValueSubject<OptionItem?, Never>(nil)
    let didSelectGradeOption = PassthroughSubject<OptionItem?, Never>()

    // Grade summary
    @Published private(set) var shouldShowGradeSummary: Bool = false
    @Published private(set) var pointsRowModel: PointsRowViewModel?
    @Published private(set) var latePenaltyRowModel: LatePenaltyRowViewModel?
    @Published private(set) var finalGradeRowModel: FinalGradeRowViewModel?

    // Error alert
    @Published var isShowingErrorAlert: Bool = false
    private(set) var errorAlertViewModel: ErrorAlertViewModel = .init()

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

        self.gradeState = GradeStateInteractorLive.gradeState(usingOnly: assignment)

        self.shouldShowPointsInput = [.gpa_scale, .letter_grade].contains(assignment.gradingType)

        self.shouldShowSlider = !assignment.useRubricForGrading
            && [.points, .percent, .gpa_scale, .letter_grade].contains(assignment.gradingType)

        self.shouldShowSelector = [.pass_fail].contains(assignment.gradingType)

        updateGradeState(gradeState)

        updateGradeOnGradePickerSelection()
        observeGradeStateChanges()
    }

    // MARK: - User Actions

    func removeGrade() {
        saveGrade(grade: "")
    }

    func excuseStudent() {
        saveGrade(excused: true)
    }

    func setGradeFromTextField(_ text: String, inputType: GradeInputTextFieldCell.InputType) {
        guard let value = text.doubleValueByFixingDecimalSeparator else {
            showInvalidGradeError(grade: text)
            return
        }

        switch inputType {
        case .points: setPointsGrade(value)
        case .percentage: setPercentGrade(value)
        }
    }

    func setPointsGrade(_ points: Double) {
        saveGrade(grade: String(points))
    }

    func setPercentGrade(_ percent: Double) {
        let percentValue = "\(round(percent))%"
        saveGrade(grade: percentValue)
    }

    func setGradeOption(_ item: OptionItem) {
        saveGrade(grade: item.id)
    }

    // MARK: - Private Methods

    private func observeGradeStateChanges() {
        gradeInteractor.gradeState
            .removeDuplicates()
            .sink { [weak self] in
                self?.updateGradeState($0)
            }
            .store(in: &cancellables)
    }

    private func updateGradeOnGradePickerSelection() {
        didSelectGradeOption
            // Not removing duplicates, because it would swallow reselecting the last selected option
            // if it was deselected in the meantime from elsewhere.
            .sink { [weak self] in
                if let gradeOption = $0 {
                    self?.setGradeOption(gradeOption)
                } else {
                    self?.removeGrade()
                }
            }
            .store(in: &cancellables)
    }

    private func updateGradeState(_ gradeState: GradeState ) {
        self.gradeState = gradeState

        gradeInputType = gradeState.gradeInputType
        sliderValue = gradeState.score
        isNoGradeButtonDisabled = (!gradeState.isGraded && !gradeState.isExcused)

        if gradeState.gradeOptions.isNotEmpty {
            let selectedOption = gradeState.gradeOptions.option(with: gradeState.originalGrade)
            selectGradeOption.send(selectedOption)
        }

        shouldShowGradeSummary = (!gradeState.isExcused && gradeState.gradingType != .not_graded)
        pointsRowModel = gradeState.pointsRowModel
        latePenaltyRowModel = gradeState.latePenaltyRowModel
        finalGradeRowModel = gradeState.finalGradeRowModel
    }

    private func saveGrade(excused: Bool? = nil, grade: String? = nil) {
        isSavingGrade.send(true)

        gradeInteractor.saveGrade(excused: excused, grade: grade)
            .receive(on: mainScheduler)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isSavingGrade.send(false)
                    if case .failure(let error) = completion {
                        self?.showError(error)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

    private func showError(_ error: Error) {
        errorAlertViewModel = .init(message: error.localizedDescription)
        isShowingErrorAlert = true
    }

    private func showInvalidGradeError(grade: String) {
        errorAlertViewModel = .init(
            title: String(localized: "Invalid Grade", bundle: .teacher),
            message: String(localized: "\"\(grade)\" is not a valid grade.", bundle: .teacher)
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
            suffixType: suffix,
            isGradedButNotPosted: isGradedButNotPosted
        )
    }
}

private extension GradeState {
    var gradeInputType: GradeInputType {
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
            .statusDisplayOnly
        }
    }
}

private extension String {
    private static let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current
        return formatter
    }()

    /// API expects US formatted numbers, which use "." as decimal separator, but users may use a different separator.
    /// For example keyboard provides a localized separator.
    var doubleValueByFixingDecimalSeparator: Double? {
        if let value = Double(self) {
            return value
        }

        return Self.numberFormatter.number(from: self)?.doubleValue
    }
}
