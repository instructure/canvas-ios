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

class GradeViewModel: ObservableObject {

    // MARK: - Outputs

    @Published var sliderValue: Double = 0
    @Published var isShowingErrorAlert = false
    @Published private(set) var state = GradeState()
    @Published private(set) var isSaving = false
    @Published private(set) var errorAlertViewModel = ErrorAlertViewModel(
        title: "",
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

        setupBindings()
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

    private func setupBindings() {
        gradeInteractor.gradeState
            .sink { [weak self] newState in
                self?.state = newState
                self?.sliderValue = newState.score
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
            title: String(localized: "Error", bundle: .core),
            message: error.localizedDescription,
            buttonTitle: String(localized: "OK", bundle: .teacher)
        )
        isShowingErrorAlert = true
    }
}
