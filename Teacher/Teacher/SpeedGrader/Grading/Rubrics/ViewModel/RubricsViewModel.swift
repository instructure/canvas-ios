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

    // MARK: - Outputs

    @Published private(set) var isSaving = false
    @Published private(set) var submission: Submission

    private(set) var criterionViewModels: [RubricCriterionViewModel] = []
    let interactor: RubricGradingInteractor

    var controller = WeakViewController()

    // MARK: - Private

    private let router: Router
    private var subscriptions = Set<AnyCancellable>()

    // MARK: - Public Methods

    init(
        assignment: Assignment,
        submission: Submission,
        interactor: RubricGradingInteractor,
        router: Router
    ) {
        self.submission = submission
        self.interactor = interactor
        self.router = router

        criterionViewModels = (assignment.rubric ?? []).map { criterion in
            return RubricCriterionViewModel(
                criterion: criterion,
                isFreeFormCommentsEnabled: assignment.freeFormCriterionCommentsOnRubric,
                hideRubricPoints: assignment.hideRubricPoints,
                interactor: interactor
            )
        }

        interactor
            .isSaving
            .assign(to: &$isSaving)

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
