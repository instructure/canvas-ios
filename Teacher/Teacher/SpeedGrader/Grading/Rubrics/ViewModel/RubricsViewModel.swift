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

import Core
import Combine
import SwiftUI

class RubricsViewModel: ObservableObject {
    @Published private(set) var isSaving = false
    @Published var rubricComment: String = ""
    @Published var rubricCommentID: String?
    let assignment: Assignment
    @Published var submission: Submission
    private(set) var criteriaViewModels: [RubricCriteriaViewModel] = []
    let interactor: RubricGradingInteractor
    @Published var totalRubricScore: Double = 0
    @Published var isRubricScoreAvailable = false

    // MARK: - Inputs
    var controller = WeakViewController() {
        didSet {
            criteriaViewModels.forEach { $0.controller = controller }
        }
    }

    // MARK: - Private
    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Public Methods

    init(
        assignment: Assignment,
        submission: Submission,
        interactor: RubricGradingInteractor,
        router: Router = AppEnvironment.shared.router
    ) {
        self.assignment = assignment
        self.submission = submission
        self.interactor = interactor
        self.router = router
        criteriaViewModels = (assignment.rubric ?? []).map { [unowned self] criteria in
            let rubricCommentBinding = Binding(
                get: { self.rubricComment },
                set: { self.rubricComment = $0 }
            )
            let rubricCommentIdBinding = Binding(
                get: { self.rubricCommentID },
                set: { self.rubricCommentID = $0 }
            )
            return RubricCriteriaViewModel(
                criteria: criteria,
                isFreeFormCommentsEnabled: assignment.freeFormCriterionCommentsOnRubric,
                interactor: interactor,
                rubricComment: rubricCommentBinding,
                rubricCommentID: rubricCommentIdBinding
            )
        }

        interactor
            .isSaving
            .assign(to: &$isSaving)

        interactor
            .isRubricScoreAvailable
            .assign(to: &$isRubricScoreAvailable)

        interactor
            .totalRubricScore
            .assign(to: &$totalRubricScore)

        interactor
            .showSaveError
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &subscriptions)
    }

    // MARK: - Private Methods

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(AlertAction(String(localized: "OK", bundle: .teacher), style: .default))
        router.show(alert, from: controller, options: .modal())
    }
}
