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

    // MARK: - Input / Output

    @Published var criterionComment: String = ""
    @Published var commentingOnCriterionID: String?

    // MARK: - Outputs

    @Published private(set) var isSaving = false
    @Published private(set) var submission: Submission
    @Published private(set) var totalRubricScore: Double = 0
    @Published private(set) var isRubricScoreAvailable = false
    private(set) var criterionViewModels: [RubricCriterionViewModel] = []
    let interactor: RubricGradingInteractor
    let maximumRubricPoints: Double

    // MARK: - Inputs

    var controller = WeakViewController() {
        didSet {
            criterionViewModels.forEach { $0.controller = controller }
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
        self.submission = submission
        self.interactor = interactor
        self.router = router
        self.maximumRubricPoints = assignment.rubricPointsPossible ?? 0
        criterionViewModels = (assignment.rubric ?? []).map { [unowned self] criterion in
            let rubricCommentBinding = Binding(
                get: { self.criterionComment },
                set: { self.criterionComment = $0 }
            )
            let rubricCommentIdBinding = Binding(
                get: { self.commentingOnCriterionID },
                set: { self.commentingOnCriterionID = $0 }
            )
            return RubricCriterionViewModel(
                criterion: criterion,
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

    func saveComment() {
        guard let commentingOnCriterionID else {
            return
        }
        interactor.updateComment(criterionId: commentingOnCriterionID, comment: criterionComment)
        self.commentingOnCriterionID = nil
    }

    // MARK: - Private Methods

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: nil, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(AlertAction(String(localized: "OK", bundle: .teacher), style: .default))
        router.show(alert, from: controller, options: .modal())
    }
}
